require 'test_helper'
require 'mocha/setup'

class CachedResqueInstanceTest < MiniTest::Test
  include Mocha::API
  def setup
    @name = "foobar"
    @resque_instance = stub(name: @name)
    @cached_resque_instance = CachedResqueInstance.new(@resque_instance)
    Rails.cache.clear
  end

  def teardown
    mocha_teardown
  end
  %w(failed running running_too_long waiting waiting_by_queue jobs_running jobs_waiting schedule jobs_failed).each do |method|
    define_method "test_#{method}_no_data_in_cache" do
      mocked_result = "whatever"
      @resque_instance.expects(method.to_sym).returns(mocked_result)

      result = @cached_resque_instance.send(method)

      assert_equal mocked_result,result
      assert_equal result,Rails.cache.fetch("ResqueInstance:foobar:#{method}")
      mocha_verify
    end

    define_method "test_#{method}_with_data_in_cache" do
      mocked_result = "whatever2"
      Rails.cache.write("ResqueInstance:foobar:#{method}",mocked_result)

      result = @cached_resque_instance.send(method)

      assert_equal mocked_result,result
      mocha_verify
    end
  end

  {
    name: [],
    resque_data_store: [],
    kill_worker: [ "some worker id" ],
  }.each do |method,args|
    define_method "test_#{method}" do
      mocked_result = "whatever"
      @resque_instance.expects(method.to_sym).with(*args).returns(mocked_result)

      result = @cached_resque_instance.send(method,*args)

      assert_equal mocked_result,result
      mocha_verify
    end
  end
  {
    retry_job: [ 2 ],
    clear_job: [ 3 ],
    retry_all: [],
    clear_all: [],
  }.each do |method,args|
    define_method "test_#{method}_clears_failed_jobs_cache" do
      Rails.cache.write("ResqueInstance:foobar:failed",100)
      Rails.cache.write("ResqueInstance:foobar:jobs_failed",[ "some", "data" ])
      new_result = "foobar"
      @resque_instance.expects(method.to_sym).with(*args).returns(new_result)

      result = @cached_resque_instance.send(method,*args)

      assert_equal new_result,result
      assert_nil   Rails.cache.fetch("ResqueInstance:foobar:failed")
      assert_nil   Rails.cache.fetch("ResqueInstance:foobar:jobs_failed")
      mocha_verify
    end
  end

  def test_queue_job_from_schedule_clears_various_caches
      Rails.cache.write("ResqueInstance:foobar:jobs_waiting","foobar")
      Rails.cache.write("ResqueInstance:foobar:jobs_running","foobar")
      Rails.cache.write("ResqueInstance:foobar:waiting_by_queue","foobar")

      new_result = "foobar"
      schedule_element = ScheduleElement.new
      @resque_instance.expects(:queue_job_from_schedule).with(schedule_element).returns(new_result)

      result = @cached_resque_instance.queue_job_from_schedule(schedule_element)
      assert_equal new_result,result
      assert_nil   Rails.cache.fetch("ResqueInstance:foobar:jobs_waiting")
      assert_nil   Rails.cache.fetch("ResqueInstance:foobar:jobs_running")
      assert_nil   Rails.cache.fetch("ResqueInstance:foobar:waiting_by_queue")
      mocha_verify
  end

  def test_jobs_failed_with_args_delegates_and_skips_cache
    mocked_result = "whatever"
    @resque_instance.expects(:jobs_failed).with(2,3).returns(mocked_result)

    result = @cached_resque_instance.jobs_failed(2,3)

    assert_equal mocked_result,result
    mocha_verify
  end
end
