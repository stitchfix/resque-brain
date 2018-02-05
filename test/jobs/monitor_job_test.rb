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

  def test_failed_statsd
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_statsd_notifier,
                                           checker: mock_checker(Monitoring::FailedJobCheck)).returns(monitor)
    monitor.expects(:monitor!)

    MonitorJob.perform("Monitoring::FailedJobCheck","Monitoring::StatsdNotifier")
    mocha_verify
  end

  def test_queue_sizes_statsd
    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: mock_statsd_notifier,
                                           checker: mock_checker(Monitoring::QueueSizeCheck)).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform("Monitoring::QueueSizeCheck","Monitoring::StatsdNotifier")
    mocha_verify
  end

  def test_unhandled_check_name
    assert_raises(NameError) do
      MonitorJob.perform("Foobar","BLAH")
    end
    mocha_verify
  end

  def test_aws_notifier
    monitor = stub

    Monitoring::Monitor.expects(:new).with(
      notifier: mock_aws_notifier(namespace: "StitchFix/iZombie", metric_name: "iz-job-queue-depth"),
       checker: mock_checker(Monitoring::QueueSizeCheck)
    ).returns(monitor)

    monitor.expects(:monitor!)

    MonitorJob.perform("Monitoring::QueueSizeCheck",
                       "Monitoring::AwsNotifier",
                       {
                         "namespace"   => "StitchFix/iZombie",
                         "metric_name" => "iz-job-queue-depth",
                       }
                      )
    mocha_verify
  end

private

  def mock_aws_notifier(namespace: , metric_name: )
    mock("Monitoring::AwsNotifier").tap { |notifier|
      Monitoring::AwsNotifier.expects(:new).with(namespace: namespace, metric_name: metric_name).returns(notifier)
    }
  end

  def mock_statsd_notifier(unit: "jobs", type: :default)
    mock("Monitoring::StatsdNotifier").tap { |notifier|
      klass = Monitoring::StatsdNotifier
      klass.expects(:new).with().returns(notifier)
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
