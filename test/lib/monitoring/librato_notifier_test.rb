# frozen_string_literal: true

require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'support/fake_logger'

lib_require 'monitoring/notifier'
lib_require 'monitoring/check_result'
lib_require 'monitoring/librato_notifier'

module Monitoring
end
class Monitoring::LibratoNotifierTest < MiniTest::Test
  def test_type
    assert Monitoring::LibratoNotifier.ancestors.include?(Monitoring::Notifier)
  end

  def test_logs_results
    logger = FakeLogger.new
    notifier = Monitoring::LibratoNotifier.new(logger: logger, unit: 'jobs')
    notifier.notify!([
                       Monitoring::CheckResult.new(resque_name: 'test1', check_name: 'foo.bar', check_count: 3),
                       Monitoring::CheckResult.new(resque_name: 'test2', check_name: 'foo.bar', check_count: 1),
                       Monitoring::CheckResult.new(resque_name: 'test3', check_name: 'foo.bar', check_count: 0)
                     ])

    assert_equal 'source=test1 count#foo.bar=3jobs', logger.infos[0]
    assert_equal 'source=test2 count#foo.bar=1jobs', logger.infos[1]
    assert_equal 'source=test3 count#foo.bar=0jobs', logger.infos[2]
  end

  def test_logs_results_as_measure
    logger = FakeLogger.new
    notifier = Monitoring::LibratoNotifier.new(logger: logger, type: :measure, unit: 'workers')
    notifier.notify!([
                       Monitoring::CheckResult.new(resque_name: 'test1', check_name: 'foo.bar', check_count: 3),
                       Monitoring::CheckResult.new(resque_name: 'test2', check_name: 'foo.bar', check_count: 1),
                       Monitoring::CheckResult.new(resque_name: 'test3', check_name: 'foo.bar', check_count: 0)
                     ])

    assert_equal 'source=test1 measure#foo.bar=3workers', logger.infos[0]
    assert_equal 'source=test2 measure#foo.bar=1workers', logger.infos[1]
    assert_equal 'source=test3 measure#foo.bar=0workers', logger.infos[2]
  end

  def test_logs_results_with_scope
    logger = FakeLogger.new
    notifier = Monitoring::LibratoNotifier.new(logger: logger, unit: 'workers')
    notifier.notify!([
                       Monitoring::CheckResult.new(resque_name: 'test1', scope: 'baz', check_name: 'foo.bar', check_count: 3),
                       Monitoring::CheckResult.new(resque_name: 'test2', scope: 'baz', check_name: 'foo.bar', check_count: 1),
                       Monitoring::CheckResult.new(resque_name: 'test3', scope: 'baz', check_name: 'foo.bar', check_count: 0)
                     ])

    assert_equal 'source=test1.baz count#foo.bar=3workers', logger.infos[0]
    assert_equal 'source=test2.baz count#foo.bar=1workers', logger.infos[1]
    assert_equal 'source=test3.baz count#foo.bar=0workers', logger.infos[2]
  end
end
