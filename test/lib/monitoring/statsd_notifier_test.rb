require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'mocha/setup'

lib_require 'monitoring/notifier'
lib_require 'monitoring/check_result'
lib_require 'monitoring/statsd_notifier'

module Monitoring
end
class Monitoring::StatsdNotifierTest < MiniTest::Test
  include Mocha::API

  def test_type
    assert Monitoring::StatsdNotifier.ancestors.include?(Monitoring::Notifier)
  end

  def test_gauge
    statsd = mock("statsd")
    statsd.expects(:gauge).with("resque.queue_size", 3, tags: [ "app:test1" ])
    statsd.expects(:gauge).with("resque.queue_size", 1, tags: [ "app:test2" ])
    statsd.expects(:gauge).with("resque.queue_size", 0, tags: [ "app:test3" ])
    notifier = Monitoring::StatsdNotifier.new(statsd: statsd)
    notifier.notify!([
      Monitoring::CheckResult.new(resque_name: "test1", check_name: "resque.queue_size", check_count: 3),
      Monitoring::CheckResult.new(resque_name: "test2", check_name: "resque.queue_size", check_count: 1),
      Monitoring::CheckResult.new(resque_name: "test3", check_name: "resque.queue_size", check_count: 0),
    ])
  end

  def test_gauge_with_scope
    statsd = mock("statsd")
    statsd.expects(:gauge).with("resque.queue_size", 3, tags: [ "app:test1", "queue:some_queue" ])
    statsd.expects(:gauge).with("resque.queue_size", 1, tags: [ "app:test2", "queue:some_other_queue" ])
    statsd.expects(:gauge).with("resque.queue_size", 0, tags: [ "app:test3", "queue:some_new_queue" ])
    notifier = Monitoring::StatsdNotifier.new(statsd: statsd)
    notifier.notify!([
      Monitoring::CheckResult.new(resque_name: "test1", scope: "some_queue", check_name: "resque.queue_size", check_count: 3),
      Monitoring::CheckResult.new(resque_name: "test2", scope: "some_other_queue", check_name: "resque.queue_size", check_count: 1),
      Monitoring::CheckResult.new(resque_name: "test3", scope: "some_new_queue", check_name: "resque.queue_size", check_count: 0),
    ])
  end
end
