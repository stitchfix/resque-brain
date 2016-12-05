require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'active_support/core_ext/numeric/time.rb'

require 'support/explicit_interface_implementation'
require 'support/resque_helpers'
require 'support/monitoring_helpers'

lib_require 'monitoring/checker'
lib_require 'monitoring/check_result'
lib_require 'monitoring/stale_worker_check'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/running_job'
rails_require 'models/resques'

module Monitoring
end

class Monitoring::StaleWorkerCheckTest < MiniTest::Test
  include ResqueHelpers
  include MonitoringHelpers

  def setup_resques(test1: 1, test2: 2, test3: :ignore)
    Redis.new.flushall
    resques = [
      add_workers(num_stale: test1, resque_instance: resque_instance("test1",:resque)),
      add_workers(num_stale: test2, resque_instance: resque_instance("test2",:resque2)),
    ]
    if test3 == :exception
      resques << ExceptionResque.new
    end
    Resques.new(resques)
  end

  def test_type
    assert Monitoring::StaleWorkerCheck.ancestors.include?(Monitoring::Checker)
  end

  def test_stale_workers
    resques = setup_resques(test1: 1, test2: 2)
    check = Monitoring::StaleWorkerCheck.new(resques: resques)

    results = check.check!

    assert_check_result results[0], resque_name: "test1", check_count: 1
    assert_check_result results[1], resque_name: "test2", check_count: 2
  end

  def test_no_stale_workers
    resques = setup_resques(test1: 0, test2: 0)
    check = Monitoring::StaleWorkerCheck.new(resques: resques)


    results = check.check!
    assert_check_result results[0], resque_name: "test1", check_count: 0
    assert_check_result results[1], resque_name: "test2", check_count: 0

  end

  def test_exception_on_one_redis
    resques = setup_resques(test1: 0, test2: 0, test3: :exception)
    check = Monitoring::StaleWorkerCheck.new(resques: resques)


    exception = begin
                  check.check!
                  nil
                rescue => ex
                  ex
                end
    refute_nil exception,"Expected an exception to be raised"
    assert_exception exception, message_match: /exception_resque/,
                           backtrace_includes: /monitoring_helpers.*jobs_running/
  end
end
