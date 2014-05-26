require 'integration_test_helper'
require 'support/fake_logger'
require 'support/resque_helpers'

class MonitoringTest < ActionDispatch::IntegrationTest
  include ResqueHelpers
  setup do
    Redis.new.flushall
    # Inputs to the rake tasks are Rails.logger and RESQUES, both of which we must override
    @original_logger = Rails.logger
    @original_resques = ::RESQUES
    Object.send(:remove_const,:RESQUES) if Object.const_defined?(:RESQUES)
    ResqueBrain::Application.load_tasks
  end

  teardown do
    Rails.logger = @original_logger
    Object.send(:remove_const,:RESQUES) if Object.const_defined?(:RESQUES)
    Object.const_set(:RESQUES,@original_resques)
  end

  test "failed check to librato" do
    logger = FakeLogger.new
    Rails.logger = logger

    Object.const_set(:RESQUES,Resques.new([
      add_failed_jobs(num_failed: 3, resque_instance: resque_instance("test1",:resque)),
      add_failed_jobs(num_failed: 4, resque_instance: resque_instance("test2",:resque2)),
    ]))

    Rake::Task['monitor:failed'].invoke

    assert_equal "source=test1 count#resque.failed_jobs=3",logger.infos[0]
    assert_equal "source=test2 count#resque.failed_jobs=4",logger.infos[1]
  end

  test "stale workers to librato" do
    logger = FakeLogger.new
    Rails.logger = logger

    Object.const_set(:RESQUES,Resques.new([
      add_workers(num_stale: 1, resque_instance: resque_instance("test1",:resque)),
      add_workers(num_stale: 2, resque_instance: resque_instance("test2",:resque2)),
    ]))

    Rake::Task['monitor:stale_workers'].invoke

    assert_equal "source=test1 measure#resque.stale_workers=1",logger.infos[0]
    assert_equal "source=test2 measure#resque.stale_workers=2",logger.infos[1]
  end

  test "queue sizes to librato" do
    logger = FakeLogger.new
    Rails.logger = logger

    Object.const_set(:RESQUES,Resques.new([
      add_jobs(jobs: { mail: 4, cache: 2 }, resque_instance: resque_instance("test1",:resque)),
      add_jobs(jobs: { mail: 1, admin: 2 }, resque_instance: resque_instance("test2",:resque2)),
    ]))

    Rake::Task['monitor:queue_sizes'].invoke

    assert_equal "source=test1 count#resque.queue_size.cache=2" , logger.infos[0]
    assert_equal "source=test1 count#resque.queue_size.mail=4"  , logger.infos[1]
    assert_equal "source=test2 count#resque.queue_size.admin=2" , logger.infos[2]
    assert_equal "source=test2 count#resque.queue_size.mail=1"  , logger.infos[3]
  end
end
