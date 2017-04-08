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
    define_method "test_#{method}_no_cache" do
      mocked_result = "whatever"
      @resque_instance.expects(method.to_sym).returns(mocked_result)

      result = @cached_resque_instance.send(method)

      assert_equal mocked_result,result
      assert_equal result,Rails.cache.fetch("ResqueInstance:foobar:#{method}")
      mocha_verify
    end

    define_method "test_#{method}_with_cache" do
      mocked_result = "whatever2"
      Rails.cache.write("ResqueInstance:foobar:#{method}",mocked_result)

      result = @cached_resque_instance.send(method)

      assert_equal mocked_result,result
      mocha_verify
    end
  end

  {
    retry_job: [ 2 ],
    clear_job: [ 3 ],
    retry_all: [],
    clear_all: [],
    kill_worker: [ "some worker id" ],
    queue_job_from_schedule: [ "dunno" ],
  }.each do |method,args|
    define_method "test_#{method}" do
      mocked_result = "whatever"
      @resque_instance.expects(method.to_sym).with(*args).returns(mocked_result)

      result = @cached_resque_instance.send(method,*args)

      assert_equal mocked_result,result
      mocha_verify
    end
  end

  def test_jobs_failed_with_args_delegates_and_skips_cache
    mocked_result = "whatever"
    @resque_instance.expects(:jobs_failed).with(2,3).returns(mocked_result)

    result = @cached_resque_instance.jobs_failed(2,3)

    assert_equal mocked_result,result
    mocha_verify
  end
end
