require 'quick_test_helper'
require 'minitest/autorun'
require 'mocha/setup'
rails_require 'jobs/monitor_job'

unless defined? RESQUES
  RESQUES = []
end
unless defined? Rails
  Rails = Module.new
end

class MonitorJobTest < MiniTest::Test
  include Mocha::API

  def teardown
    mocha_teardown
  end

  def test_failed
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_notifier,
                                           checker: mock_checker(Monitoring::FailedJobCheck)).returns(monitor)
    monitor.expects(:monitor!)

    MonitorJob.perform(:failed)
    mocha_verify
  end

  def test_failed_by_class
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_notifier,
                                           checker: mock_checker(Monitoring::FailedJobByClassCheck)).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform(:failed_by_class)
    mocha_verify
  end

  def test_stale_workers
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_notifier(type: :measure, unit: "workers"),
                                           checker: mock_checker(Monitoring::StaleWorkerCheck)).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform(:stale_workers)
    mocha_verify
  end

  def test_queue_sizes
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_notifier,
                                           checker: mock_checker(Monitoring::QueueSizeCheck)).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform(:queue_sizes)
    mocha_verify
  end

  def test_unhandled_check_name
    assert_raises(KeyError) do
      MonitorJob.perform(:foobar)
    end
    mocha_verify
  end

  def test_when_check_raises_error_we_raise_it_by_default
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_notifier,
                                           checker: mock_checker(Monitoring::QueueSizeCheck)).returns(monitor)
    monitor.expects(:monitor!).raises("OH NOES!")

    exception = assert_raises do
      MonitorJob.perform(:queue_sizes)
    end
    assert_equal "OH NOES!", exception.message
    mocha_verify
  end

  def test_when_check_raises_error_we_log_and_ignore_if_requested_to
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_notifier,
                                           checker: mock_checker(Monitoring::QueueSizeCheck)).returns(monitor)
    monitor.expects(:monitor!).raises("OH NOES!")

    logger = mock("Rails Logger")
    Rails.expects(:logger).returns(logger)
    logger.expects(:info).with("Ignoring RuntimeError from MonitorJob: OH NOES!")

    refute_raises do
      MonitorJob.perform(:queue_sizes, :ignore_and_log_errors)
    end
    mocha_verify
  end

private

  def mock_notifier(unit: "jobs", type: :default)
    mock("Monitoring::LibratoNotifier").tap { |notifier|
      klass = Monitoring::LibratoNotifier
      if type == :default
        klass.expects(:new).with(unit: unit).returns(notifier)
      else
        klass.expects(:new).with(type: type, unit: unit).returns(notifier)
      end
    }
  end

  def mock_checker(klass)
    mock(klass.name).tap { |checker|
      klass.expects(:new).returns(checker)
    }
  end

  def refute_raises(&block)
    block.()
  rescue => ex
    assert false,"Expected no exception, but got #{ex.message}"
  end
end
