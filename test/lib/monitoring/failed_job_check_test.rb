require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'active_support/core_ext/numeric/time.rb'

lib_require 'monitoring/checker'
lib_require 'monitoring/failed_job_check'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/failed_job'
rails_require 'models/resques'

module Monitoring
end
class Monitoring::FailedJobCheckTest < MiniTest::Test

  def setup_resques(test1: 1, test2: 2)
    Redis.new.flushall
    Resques.new([
      setup_resque("test1",:resque,test1),
      setup_resque("test2",:resque2,test2),
    ])
  end

  def setup_resque(name, namespace, num_failed)
    redis = Redis::Namespace.new(namespace,Redis.new)
    resque_data_store = Resque::DataStore.new(redis)

    num_failed.times do |i|
      resque_data_store.push_to_failed_queue(Resque.encode(
        failed_at: Time.now.utc.iso8601,
        payload: { class: "Baz", args: [ i ]},
        exception: "Resque::TermException",
        error: "SIGTERM",
        backtrace: [ "foo","bar","blah"],
        queue: "mail",
        worker: "worker#{i}",
      ))
    end

    ResqueInstance.new(name: name, resque_data_store: resque_data_store)
  end

  def test_type
    assert Monitoring::FailedJobCheck.ancestors.include?(Monitoring::Checker)
  end

  def test_failed_jobs
    resques = setup_resques(test1: 1, test2: 2)
    check = Monitoring::FailedJobCheck.new(resques: resques)

    results = check.check!

    assert_equal 1,results["test1"].size,results["test1"].inspect
    assert_equal 2,results["test2"].size,results["test2"].inspect
  end

  def test_no_failed_jobs
    resques = setup_resques(test1: 0, test2: 0)
    check = Monitoring::FailedJobCheck.new(resques: resques)

    results = check.check!

    assert_equal 0,results["test1"].size,results.inspect
    assert_equal 0,results["test2"].size,results.inspect
  end
end
