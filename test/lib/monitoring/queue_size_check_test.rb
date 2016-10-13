require 'quick_test_helper'
require 'support/resque_helpers'
require 'support/monitoring_helpers'
require 'minitest/autorun'
require 'resque'

lib_require 'monitoring/checker'
lib_require 'monitoring/queue_size_check'
lib_require 'monitoring/check_result'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/running_job'
rails_require 'models/resques'

module Monitoring
end
class Monitoring::QueueSizeCheckTest < MiniTest::Test
  include ResqueHelpers
  include MonitoringHelpers

  def setup_resques(test1: {}, test2: {})
    Redis.new.flushall
    Resques.new([
      add_jobs(jobs: test1, resque_instance: resque_instance("test1",:resque)),
      add_jobs(jobs: test2, resque_instance: resque_instance("test2",:resque2)),
    ])
  end

  def test_type
    assert Monitoring::QueueSizeCheck.ancestors.include?(Monitoring::Checker)
  end

  def test_jobs_in_queue
    resques = setup_resques(test1: { mail: 10, cache: 4 },
                            test2: { mail: 3, admin: 2 })
    check = Monitoring::QueueSizeCheck.new(resques: resques)

    results = check.check!.sort_by { |result| "#{result.resque_name}.#{result.scope}" }

    assert_check_result results[0], resque_name: "test1" , scope: "cache" , check_count: 4
    assert_check_result results[1], resque_name: "test1" , scope: "mail"  , check_count: 10
    assert_check_result results[2], resque_name: "test2" , scope: "admin" , check_count: 2
    assert_check_result results[3], resque_name: "test2" , scope: "mail"  , check_count: 3

  end
end
