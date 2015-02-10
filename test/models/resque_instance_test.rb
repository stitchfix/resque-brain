require 'quick_test_helper'
require 'minitest/autorun'
require 'support/fake_resque_data_store'
rails_require 'models/resque_instance'
rails_require 'models/job'
rails_require 'models/running_job'
rails_require 'models/failed_job'
rails_require 'models/schedule'

class ResqueInstanceTest < MiniTest::Test
  def test_failed
    assert_equal 3,create_test_instance.failed
  end

  def test_get_jobs_failed
    jobs_failed = create_test_instance.jobs_failed

    assert_equal 3,jobs_failed.size

    assert_equal   "SomeFailingJob"         , jobs_failed[0].payload["class"]
    assert_equal   [500145,1114130]         , jobs_failed[0].payload["args"]
    assert_equal   "mail"                   , jobs_failed[0].queue
    assert_equal   "SIGTERM"                , jobs_failed[0].error
    assert_equal   "Resque::TermException"  , jobs_failed[0].exception
    assert_equal   "some_worker_id"         , jobs_failed[0].worker
    assert_equal   0                        , jobs_failed[0].id
    assert_in_delta Time.now.utc - 3600     , jobs_failed[0].failed_at, 5 # seconds
    assert_nil                                jobs_failed[0].retried_at

    assert_equal   "SomeOtherFailingJob"   , jobs_failed[1].payload["class"]
    assert_equal  ["blah"]                 , jobs_failed[1].payload["args"]
    assert_equal   "cache"                 , jobs_failed[1].queue
    assert_equal   "No Such key 'foobar'"  , jobs_failed[1].error
    assert_equal   "KeyError"              , jobs_failed[1].exception
    assert_equal   "some_other_worker_id"  , jobs_failed[1].worker
    assert_equal   1                       , jobs_failed[1].id
    assert_in_delta Time.now.utc           , jobs_failed[1].failed_at, 5 # seconds
    assert_nil                               jobs_failed[1].retried_at

    assert_nil jobs_failed[2].payload["class"]
    assert_nil jobs_failed[2].payload["args"]
    assert_nil jobs_failed[2].queue
    assert_nil jobs_failed[2].exception
    assert_nil jobs_failed[2].failed_at
    assert_nil jobs_failed[2].error
    assert_equal 2, jobs_failed[2].id
  end

  def test_get_jobs_failed_paginated
    jobs_failed = create_test_instance.jobs_failed(1,1)

    assert_equal 1,jobs_failed.size

    assert_equal   "SomeOtherFailingJob"   , jobs_failed[0].payload["class"]
    assert_equal  ["blah"]                 , jobs_failed[0].payload["args"]
    assert_equal   "cache"                 , jobs_failed[0].queue
    assert_equal   "No Such key 'foobar'"  , jobs_failed[0].error
    assert_equal   "KeyError"              , jobs_failed[0].exception
    assert_equal   "some_other_worker_id"  , jobs_failed[0].worker
    assert_equal   1                       , jobs_failed[0].id
    assert_in_delta Time.now.utc           , jobs_failed[0].failed_at, 5 # seconds
    assert_nil                               jobs_failed[0].retried_at
  end


  def test_running
    assert_equal 4,create_test_instance.running
  end

  def test_running_too_long
    assert_equal 1,create_test_instance.running_too_long
  end

  def test_running_too_long_explicit_config
    resque_instance = ResqueInstance.new(name: "test3", resque_data_store: FakeResqueDataStore.new, stale_worker_seconds: 30)
    assert_equal 2,resque_instance.running_too_long
  end

  def test_get_jobs_running
    jobs_running = create_test_instance.jobs_running.sort_by { |job| job.queue }

    assert_equal    4               , jobs_running.size
    assert_equal   "cache"          , jobs_running[0].queue
    assert_equal   "cache"          , jobs_running[0].worker
    assert_equal   "CacheJob"       , jobs_running[0].payload["class"]
    assert_equal  ["whatever"]      , jobs_running[0].payload["args"]
    assert_in_delta Time.now - 3600 , jobs_running[0].started_at       , 5 # seconds
    assert                            jobs_running[0].too_long?

    assert_equal "generator"  ,  jobs_running[1].queue
    assert_equal "generator"  ,  jobs_running[1].worker
    refute                       jobs_running[1].too_long?

    assert_equal "indexing"   ,  jobs_running[2].queue
    assert_equal "indexing"   ,  jobs_running[2].worker
    refute                       jobs_running[2].too_long?

    assert_equal "purchasing" ,  jobs_running[3].queue
    assert_equal "purchasing" ,  jobs_running[3].worker
    refute                       jobs_running[3].too_long?

  end

  def test_get_jobs_waiting
    jobs_waiting = create_test_instance.jobs_waiting

    assert_equal 5, jobs_waiting["foo"].size
    
    jobs_waiting["foo"].each_with_index do |job,index|

      assert_equal index+1  , job.payload["args"][0]
      assert_equal "FooJob" , job.payload["class"]

    end

    assert_equal 2, jobs_waiting["bar"].size

    jobs_waiting["bar"].each_with_index do |job,index|

      assert_equal index+1  , job.payload["args"][0]
      assert_equal "BarJob" , job.payload["class"]

    end
  end

  def test_waiting
    assert_equal 7,create_test_instance.waiting
  end

  def test_retry_job
    resque_data_store = fake_resque_data_store
    instance = create_test_instance(resque_data_store: resque_data_store)
    instance.retry_job(1)

    refute_nil resque_data_store.queues["cache"], "Expected the retry to create the 'cache' queue, got #{resque_data_store.queues.keys}"

    queued_job = resque_data_store.queues["cache"][-1]
    assert_equal   "SomeOtherFailingJob"   , queued_job["class"]
    assert_equal  ["blah"]                 , queued_job["args"]
    assert_in_delta Time.now.utc           , instance.jobs_failed[1].retried_at, 5 # seconds

  end

  def test_clear_job
    resque_data_store = fake_resque_data_store
    instance = create_test_instance(resque_data_store: resque_data_store)

    instance.clear_job(1)

    assert_equal 2                     , instance.jobs_failed.size
    refute_equal "SomeOtherFailingJob" , instance.jobs_failed[1].payload["class"]
  end

  def test_clear_all
    resque_data_store = fake_resque_data_store
    instance = create_test_instance(resque_data_store: resque_data_store)

    instance.clear_all

    assert_equal 0, instance.jobs_failed.size
  end

  def test_retry_all
    resque_data_store = fake_resque_data_store
    instance = create_test_instance(resque_data_store: resque_data_store)

    instance.retry_all

    refute_nil resque_data_store.queues["cache"], "Expected the retry to create the 'cache' queue, got #{resque_data_store.queues.keys}"
    refute_nil resque_data_store.queues["mail"], "Expected the retry to create the 'mail' queue, got #{resque_data_store.queues.keys}"
  end

  def test_schedule
    resque_data_store = fake_resque_data_store(schedule: {
      foo: { class: "FooJob", args: [ 1, "two", true ], description: "This is a fake job", cron: "1 * * * *" },
      bar: { class: "BarJob", description: "This is another fake job", cron: "3 * * * *" },
    })
    instance = create_test_instance(resque_data_store: resque_data_store)
    schedule = instance.schedule

    assert_equal "foo",schedule[0].name
    assert_equal [1,"two",true],schedule[0].args
    assert_equal "This is a fake job",schedule[0].description
    assert_equal "1 * * * *",schedule[0].cron

    assert_equal "bar",schedule[1].name
    assert_nil   schedule[1].args
    assert_equal "This is another fake job",schedule[1].description
    assert_equal "3 * * * *",schedule[1].cron
  end

  def test_schedule_no_schedule
    resque_data_store = fake_resque_data_store(schedule: nil)
    instance = create_test_instance(resque_data_store: resque_data_store)
    schedule = instance.schedule

    assert schedule.empty?
  end

  def test_schedule_mangled_schedule
    resque_data_store = fake_resque_data_store(schedule: "blah blah blah blah whatever")
    instance = create_test_instance(resque_data_store: resque_data_store)
    schedule = instance.schedule

    assert schedule.empty?
  end

private
  def fake_resque_data_store(*args)
    FakeResqueDataStore.new(*args)
  end

  def create_test_instance(resque_data_store: fake_resque_data_store)
    ResqueInstance.new(name: "whatever", resque_data_store: resque_data_store)
  end
end
