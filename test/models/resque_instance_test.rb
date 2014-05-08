require 'quick_test_helper'
require 'minitest/autorun'
require 'support/fake_resque_data_store'
rails_require 'models/resque_instance'
rails_require 'models/job'

class ResqueInstanceTest < MiniTest::Test
  def test_failed
    assert_equal 10,create_test_instance.failed
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
    assert_equal   "CacheJob"       , jobs_running[0].payload["class"]
    assert_equal  ["whatever"]      , jobs_running[0].payload["args"]
    assert_in_delta Time.now - 3600 , jobs_running[0].started_at       , 5 # seconds
    assert                            jobs_running[0].too_long?

    assert_equal "generator"  ,  jobs_running[1].queue
    refute                       jobs_running[1].too_long?

    assert_equal "indexing"   ,  jobs_running[2].queue
    refute                       jobs_running[2].too_long?

    assert_equal "purchasing" ,  jobs_running[3].queue
    refute                       jobs_running[2].too_long?

  end

  def test_get_jobs_waiting
    jobs_waiting = create_test_instance.jobs_waiting

    assert_equal 5, jobs_waiting["foo"].size
    
    jobs_waiting["foo"].each_with_index do |job,index|

      assert_nil              job.worker
      assert_nil              job.started_at
      refute                  job.too_long?
      assert_equal index+1  , job.payload["args"][0]
      assert_equal "FooJob" , job.payload["class"]

    end

    assert_equal 2, jobs_waiting["bar"].size

    jobs_waiting["bar"].each_with_index do |job,index|

      assert_nil              job.worker
      assert_nil              job.started_at
      refute                  job.too_long?
      assert_equal index+1  , job.payload["args"][0]
      assert_equal "BarJob" , job.payload["class"]

    end
  end

  def test_waiting
    assert_equal 7,create_test_instance.waiting
  end

private

  def create_test_instance
    ResqueInstance.new(name: "whatever", resque_data_store: FakeResqueDataStore.new)
  end
end
