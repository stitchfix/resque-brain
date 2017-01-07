require 'quick_test_helper'
require 'minitest/autorun'
require 'mocha/setup'
rails_require 'jobs/monitor_job'

unless defined? RESQUES
  RESQUES = []
end
class MonitorJobTest < MiniTest::Test
  include Mocha::API
  def test_failed
    notifier = mock("Monitoring::LibratoNotifier")
    checker = mock("Monitoring::FailedJobCheck")
    Monitoring::LibratoNotifier.expects(:new).with(unit: "jobs").returns(notifier).at_least_once
    Monitoring::LibratoNotifier.expects(:new).with(type: :measure, unit: "workers").returns(notifier).at_least_once
    Monitoring::FailedJobCheck.expects(:new).returns(checker)
    Monitoring::FailedJobByClassCheck.expects(:new)
    Monitoring::StaleWorkerCheck.expects(:new)
    Monitoring::QueueSizeCheck.expects(:new)

    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: notifier,checker: checker).returns(monitor)
    monitor.expects(:monitor!)

    MonitorJob.perform(:failed)
  end
  def test_failed_by_class
    notifier = mock("Monitoring::LibratoNotifier")
    checker = mock("Monitoring::FailedJobByClassCheck")
    Monitoring::LibratoNotifier.expects(:new).with(unit: "jobs").returns(notifier).at_least_once
    Monitoring::LibratoNotifier.expects(:new).with(type: :measure, unit: "workers").returns(notifier).at_least_once
    Monitoring::FailedJobByClassCheck.expects(:new).returns(checker)
    Monitoring::FailedJobCheck.expects(:new)
    Monitoring::StaleWorkerCheck.expects(:new)
    Monitoring::QueueSizeCheck.expects(:new)

    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: notifier,checker: checker).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform(:failed_by_class)
  end
  def test_stale_workers
    notifier = mock("Monitoring::LibratoNotifier")
    checker = mock("Monitoring::StaleWorkerCheck")
    Monitoring::LibratoNotifier.expects(:new).with(unit: "jobs").returns(notifier).at_least_once
    Monitoring::LibratoNotifier.expects(:new).with(type: :measure, unit: "workers").returns(notifier).at_least_once
    Monitoring::StaleWorkerCheck.expects(:new).returns(checker)
    Monitoring::FailedJobCheck.expects(:new)
    Monitoring::FailedJobByClassCheck.expects(:new)
    Monitoring::QueueSizeCheck.expects(:new)

    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: notifier,checker: checker).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform(:stale_workers)
  end
  def test_queue_sizes
    notifier = mock("Monitoring::LibratoNotifier")
    checker = mock("Monitoring::QueueSizeCheck")
    Monitoring::LibratoNotifier.expects(:new).with(unit: "jobs").returns(notifier).at_least_once
    Monitoring::LibratoNotifier.expects(:new).with(type: :measure, unit: "workers").returns(notifier).at_least_once
    Monitoring::StaleWorkerCheck.expects(:new)
    Monitoring::FailedJobCheck.expects(:new)
    Monitoring::FailedJobByClassCheck.expects(:new)
    Monitoring::QueueSizeCheck.expects(:new).returns(checker)

    monitor = stub
    Monitoring::Monitor.expects(:new).with(notifier: notifier,checker: checker).returns(monitor)
    monitor.expects(:monitor!)
    MonitorJob.perform(:queue_sizes)
  end
end
