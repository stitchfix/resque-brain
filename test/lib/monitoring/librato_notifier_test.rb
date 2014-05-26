require 'quick_test_helper'
require 'minitest/autorun'
require 'resque'
require 'support/fake_logger'

lib_require 'monitoring/notifier'
lib_require 'monitoring/librato_notifier'

module Monitoring
end
class Monitoring::LibratoNotifierTest < MiniTest::Test

  def test_type
    assert Monitoring::LibratoNotifier.ancestors.include?(Monitoring::Notifier)
  end

  def test_requires_a_prefix
    assert_raises ArgumentError do
      Monitoring::LibratoNotifier.new(logger: FakeLogger.new)
    end
  end

  def test_prefix_should_just_have_alpha_nums_and_dots
    assert_raises ArgumentError do
      Monitoring::LibratoNotifier.new(prefix: "foo bar", logger: FakeLogger.new)
    end
  end

  def test_logs_results
    logger = FakeLogger.new
    notifier = Monitoring::LibratoNotifier.new(prefix: "foo.bar", logger: logger)
    notifier.notify!({
      "test1" => [ Object.new, Object.new, Object.new ],
      "test2" => [ Object.new ],
      "test3" => [],
    })

    assert_equal "source=test1 count#foo.bar=3", logger.infos[0]
    assert_equal "source=test2 count#foo.bar=1", logger.infos[1]
    assert_equal "source=test3 count#foo.bar=0", logger.infos[2]
  end

  def test_logs_results_as_measure
    logger = FakeLogger.new
    notifier = Monitoring::LibratoNotifier.new(prefix: "foo.bar", logger: logger, type: :measure)
    notifier.notify!({
      "test1" => [ Object.new, Object.new, Object.new ],
      "test2" => [ Object.new ],
      "test3" => [],
    })

    assert_equal "source=test1 measure#foo.bar=3", logger.infos[0]
    assert_equal "source=test2 measure#foo.bar=1", logger.infos[1]
    assert_equal "source=test3 measure#foo.bar=0", logger.infos[2]
  end
end
