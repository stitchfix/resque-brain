require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'active_support/core_ext/numeric/time.rb'

require 'support/explicit_interface_implementation'

lib_require 'monitoring/checker'
lib_require 'monitoring/stale_worker_check'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/running_job'
rails_require 'models/resques'

module Monitoring
end
class Monitoring::StaleWorkerCheckTest < MiniTest::Test

  def setup_resques(test1: 1, test2: 2)
    Redis.new.flushall
    Resques.new([
      setup_resque("test1",:resque,test1),
      setup_resque("test2",:resque2,test2),
    ])
  end

  def setup_resque(name, namespace, num_stale)
    redis = Redis::Namespace.new(namespace,Redis.new)
    resque_data_store = Resque::DataStore.new(redis)

    num_workers = [num_stale,2].max

    (0..(num_stale-1)).each do |i|
      worker = Resque::Worker.new("#{name}_mail#{i}")
      resque_data_store.register_worker(worker)
      resque_data_store.set_worker_payload(
        worker,
        Resque.encode(
          :queue   => "#{name}_mail#{i}",
          :run_at  => (Time.now - 2.hours).utc.iso8601,
          :payload => { class: "RunningTypeJob", args: [4,5,6] }
        )
      )
    end
    (num_stale..(num_workers-1)).each do |i|
      worker = Resque::Worker.new("#{name}_cache#{i}")
      resque_data_store.register_worker(worker)
      resque_data_store.set_worker_payload(
        worker,
        Resque.encode(
          :queue   => "#{name}_cache#{i}",
          :run_at  => Time.now.utc.iso8601,
          :payload => { class: "RunningTypeJob", args: [4,5,6] }
        )
      )
    end
    ResqueInstance.new(name: name, resque_data_store: resque_data_store)
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
