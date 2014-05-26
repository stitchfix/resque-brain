require 'quick_test_helper'
require 'support/resque_helpers'
require 'minitest/autorun'
require 'resque'

lib_require 'monitoring/checker'
lib_require 'monitoring/queue_size_check'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/running_job'
rails_require 'models/resques'

module Monitoring
end
class Monitoring::QueueSizeCheckTest < MiniTest::Test
  include ResqueHelpers

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

    results = check.check!

    assert_equal 10, results["test1"]["mail"].size
    assert_equal 4 , results["test1"]["cache"].size

    assert_equal 3 , results["test2"]["mail"].size
    assert_equal 2 , results["test2"]["admin"].size
  end
end
