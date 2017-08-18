# frozen_string_literal: true

require 'quick_test_helper'
require 'minitest/autorun'
require 'ostruct'
require 'support/explicit_interface_implementation'

lib_require 'monitoring/checker'
lib_require 'monitoring/notifier'
lib_require 'monitoring/monitor'

class FakeNotifier
  extend ExplicitInterfaceImplementation
  implements Monitoring::Notifier

  attr_reader :notified
  implement! def notify!(results)
    @notified = results
  end
end

class FakeChecker
  extend ExplicitInterfaceImplementation
  implements Monitoring::Checker
  def initialize(value)
    @value = value
  end

  implement! def check!
    @value
  end
end

module Monitoring
end
class Monitoring::MonitorTest < MiniTest::Test
  def test_check_where_nothing_is_wrong
    notifier = FakeNotifier.new
    results = Object.new
    checker = FakeChecker.new(results)
    monitor = Monitoring::Monitor.new(checker: checker, notifier: notifier)
    monitor.monitor!

    assert_equal results, notifier.notified
  end
end
