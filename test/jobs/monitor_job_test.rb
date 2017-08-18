# frozen_string_literal: true

require 'quick_test_helper'
require 'minitest/autorun'
require 'mocha/setup'
rails_require 'jobs/monitor_job'

RESQUES = [].freeze unless defined? RESQUES
Rails = Module.new unless defined? Rails

class MonitorJobTest < MiniTest::Test
  include Mocha::API

  def teardown
    mocha_teardown
  end

  def test_failed
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_librato_notifier,
                                           checker: mock_checker(Monitoring::FailedJobCheck)).returns(monitor)
    monitor.expects(:monitor!)

    MonitorJob.perform('Monitoring::FailedJobCheck')
    mocha_verify
  end

  def test_failed_by_class
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_librato_notifier,
                                           checker: mock_checker(Monitoring::FailedJobByClassCheck)).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform('Monitoring::FailedJobByClassCheck')
    mocha_verify
  end

  def test_stale_workers
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_librato_notifier(type: 'measure', unit: 'workers'),
                                           checker: mock_checker(Monitoring::StaleWorkerCheck)).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform('Monitoring::StaleWorkerCheck',
                       'Monitoring::LibratoNotifier',
                       'type' => 'measure',
                       'unit' => 'workers')
    mocha_verify
  end

  def test_queue_sizes
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_librato_notifier,
                                           checker: mock_checker(Monitoring::QueueSizeCheck)).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform('Monitoring::QueueSizeCheck')
    mocha_verify
  end

  def test_unhandled_check_name
    assert_raises(NameError) do
      MonitorJob.perform('Foobar')
    end
    mocha_verify
  end

  def test_when_check_raises_error_we_log_and_ignore
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_librato_notifier,
                                           checker: mock_checker(Monitoring::QueueSizeCheck)).returns(monitor)
    monitor.expects(:monitor!).raises('OH NOES!')

    logger = mock('Rails Logger')
    Rails.expects(:logger).returns(logger)
    logger.expects(:info).with('Ignoring RuntimeError from MonitorJob: OH NOES!')

    refute_raises do
      MonitorJob.perform('Monitoring::QueueSizeCheck')
    end
    mocha_verify
  end

  def test_aws_notifier
    monitor = stub

    Monitoring::Monitor.expects(:new).with(
      notifier: mock_aws_notifier(namespace: 'StitchFix/iZombie', metric_name: 'iz-job-queue-depth'),
      checker: mock_checker(Monitoring::QueueSizeCheck)
    ).returns(monitor)

    monitor.expects(:monitor!)

    MonitorJob.perform('Monitoring::QueueSizeCheck',
                       'Monitoring::AwsNotifier',
                       'namespace' => 'StitchFix/iZombie',
                       'metric_name' => 'iz-job-queue-depth')
    mocha_verify
  end

  private

  def mock_aws_notifier(namespace:, metric_name:)
    mock('Monitoring::AwsNotifier').tap do |notifier|
      Monitoring::AwsNotifier.expects(:new).with(namespace: namespace, metric_name: metric_name).returns(notifier)
    end
  end

  def mock_librato_notifier(unit: 'jobs', type: :default)
    mock('Monitoring::LibratoNotifier').tap do |notifier|
      klass = Monitoring::LibratoNotifier
      if type == :default
        klass.expects(:new).with(unit: unit).returns(notifier)
      else
        klass.expects(:new).with(type: type, unit: unit).returns(notifier)
      end
    end
  end

  def mock_checker(klass)
    mock(klass.name).tap do |checker|
      klass.expects(:new).returns(checker)
    end
  end

  def refute_raises
    yield
  rescue => ex
    assert false, "Expected no exception, but got #{ex.message}"
  end
end
