require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'support/fake_logger'

lib_require 'monitoring/notifier'
lib_require 'monitoring/librato_notifier'
lib_require 'monitoring/per_queue_librato_notifier'

module Monitoring
end
class Monitoring::PerQueueLibratoNotifierTest < MiniTest::Test

  def test_type
    assert Monitoring::PerQueueLibratoNotifier.ancestors.include?(Monitoring::Notifier)
  end

  def test_requires_a_prefix
    assert_raises ArgumentError do
      Monitoring::PerQueueLibratoNotifier.new(logger: FakeLogger.new)
    end
  end

  def test_prefix_should_just_have_alpha_nums_and_dots
    assert_raises ArgumentError do
      Monitoring::PerQueueLibratoNotifier.new(prefix: "foo bar", logger: FakeLogger.new)
    end
  end

  def test_logs_results
    logger = FakeLogger.new
    notifier = Monitoring::PerQueueLibratoNotifier.new(prefix: "foo.bar", logger: logger)
    notifier.notify!(
      "test1" => {
        "mail"  =>  [ Object.new, Object.new, Object.new ],
        "cache" => [ Object.new, Object.new, Object.new, Object.new ],
      },
      "test2" => {
        "mail" => [ Object.new ],
      },
      "test3" => {
        "mail"  => [],
        "cache" => [ Object.new],
      }
    )

    # Sorts by queue within a resque for predictability
    assert_equal "source=test1 count#foo.bar.cache=4", logger.infos[0]
    assert_equal "source=test1 count#foo.bar.mail=3",  logger.infos[1]
    assert_equal "source=test2 count#foo.bar.mail=1",  logger.infos[2]
    assert_equal "source=test3 count#foo.bar.cache=1", logger.infos[3]
    assert_equal "source=test3 count#foo.bar.mail=0",  logger.infos[4]
  end
end
