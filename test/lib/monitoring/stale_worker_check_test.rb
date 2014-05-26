require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'active_support/core_ext/numeric/time.rb'

require 'support/explicit_interface_implementation'
require 'support/resque_helpers'

lib_require 'monitoring/checker'
lib_require 'monitoring/stale_worker_check'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/running_job'
rails_require 'models/resques'

module Monitoring
end
class Monitoring::StaleWorkerCheckTest < MiniTest::Test
  include ResqueHelpers

  def setup_resques(test1: 1, test2: 2)
    Redis.new.flushall
    Resques.new([
      add_workers(num_stale: test1, resque_instance: resque_instance("test1",:resque)),
      add_workers(num_stale: test2, resque_instance: resque_instance("test2",:resque2)),
    ])
  end

  def test_type
    assert Monitoring::StaleWorkerCheck.ancestors.include?(Monitoring::Checker)
  end

  def test_stale_workers
    resques = setup_resques(test1: 1, test2: 2)
    check = Monitoring::StaleWorkerCheck.new(resques: resques)

    results = check.check!

    assert_equal 1,results["test1"].size,results["test1"].inspect
    assert_equal 2,results["test2"].size,results["test2"].inspect
  end

  def test_no_stale_workers
    resques = setup_resques(test1: 0, test2: 0)
    check = Monitoring::StaleWorkerCheck.new(resques: resques)

    results = check.check!

    assert_equal 0,results["test1"].size,results.inspect
    assert_equal 0,results["test2"].size,results.inspect
  end
end
