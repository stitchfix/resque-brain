require 'integration_test_helper'
require 'support/fake_logger'
require 'support/resque_helpers'

class MonitoringTest < ActionDispatch::IntegrationTest
  include ResqueHelpers
  setup do
    Redis.new.flushall
    @original_logger = Rails.logger
  end

  teardown do
    Rails.logger = @original_logger
  end

  test "failed check to librato" do
    resques = Resques.new([
      add_failed_jobs(num_failed: 3, resque_instance: resque_instance("test1",:resque)),
      add_failed_jobs(num_failed: 4, resque_instance: resque_instance("test2",:resque2)),
    ])

    logger = FakeLogger.new
    Rails.logger = logger

    monitor = Monitoring::Monitor.new(checker: Monitoring::FailedJobCheck.new(resques: resques),
                                      notifier: Monitoring::LibratoNotifier.new(prefix: "resque.failed_jobs"))

    monitor.monitor!

    assert_equal "source=test1 count#resque.failed_jobs=3",logger.infos[0]
    assert_equal "source=test2 count#resque.failed_jobs=4",logger.infos[1]
  end

  test "stale workers to librato" do
    resques = Resques.new([
      add_workers(num_stale: 1, resque_instance: resque_instance("test1",:resque)),
      add_workers(num_stale: 2, resque_instance: resque_instance("test2",:resque2)),
    ])

    logger = FakeLogger.new
    Rails.logger = logger

    monitor = Monitoring::Monitor.new(checker: Monitoring::StaleWorkerCheck.new(resques: resques),
                                      notifier: Monitoring::LibratoNotifier.new(prefix: "resque.stale_workers", type: :measure))

    monitor.monitor!

    assert_equal "source=test1 measure#resque.stale_workers=1",logger.infos[0]
    assert_equal "source=test2 measure#resque.stale_workers=2",logger.infos[1]
  end
end
