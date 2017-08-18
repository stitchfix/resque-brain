# frozen_string_literal: true

require 'quick_test_helper'
require 'support/resque_helpers'
require 'support/monitoring_helpers'
require 'minitest/autorun'
require 'resque'

lib_require 'monitoring/checker'
lib_require 'monitoring/check_result'
lib_require 'monitoring/failed_job_check'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/failed_job'
rails_require 'models/resques'

module Monitoring
end
class Monitoring::FailedJobCheckTest < MiniTest::Test
  include ResqueHelpers
  include MonitoringHelpers

  def setup_resques(test1: ['BazJob'], test2: %w[FooJob BarJob], test3: :ignore)
    Redis.new.flushall
    Resques.new([
      add_failed_jobs(job_class_names: test1, resque_instance: resque_instance('test1', :resque)),
      add_failed_jobs(job_class_names: test2, resque_instance: resque_instance('test2', :resque2)),
      test3 == :exception ? ExceptionResque.new : nil
    ].compact)
  end

  def test_type
    assert Monitoring::FailedJobCheck.ancestors.include?(Monitoring::Checker)
  end

  def test_failed_jobs
    resques = setup_resques
    check = Monitoring::FailedJobCheck.new(resques: resques)

    results = check.check!

    assert_check_result results[0], resque_name: 'test1', check_count: 1
    assert_check_result results[1], resque_name: 'test2', check_count: 2
  end

  def test_no_failed_jobs
    resques = setup_resques(test1: [], test2: [])
    check = Monitoring::FailedJobCheck.new(resques: resques)

    results = check.check!

    assert_check_result results[0], resque_name: 'test1', check_count: 0
    assert_check_result results[1], resque_name: 'test2', check_count: 0
  end

  def test_exception_on_one_redis
    resques = setup_resques(test3: :exception)
    check = Monitoring::FailedJobCheck.new(resques: resques)

    exception = begin
                  check.check!
                  nil
                rescue => ex
                  ex
                end
    refute_nil exception, 'Expected an exception to be raised'
    assert_exception exception, message_match: /exception_resque/,
                                backtrace_includes: /monitoring_helpers.*failed/
  end
end
