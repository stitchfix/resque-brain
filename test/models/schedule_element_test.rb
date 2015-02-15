require 'test_helper'

class ScheduleElementTest < MiniTest::Test
  def test_frequency_in_words_no_timezone
    schedule = ScheduleElement.new(cron: "1 2 3 4 5")
    assert_equal Cron2English.parse("1 2 3 4 5").join(' '),schedule.frequency_in_words
  end

  def test_frequency_in_words_with_timezone
    schedule = ScheduleElement.new(cron: "1 2 3 4 5 America/New_York")
    assert_equal Cron2English.parse("1 2 3 4 5").join(' ') + " EST",schedule.frequency_in_words
    assert_equal "1 2 3 4 5 America/New_York", schedule.cron
  end

  def test_frequency_in_words_with_weird_timezone
    schedule = ScheduleElement.new(cron: "1 2 3 4 5 BLAH")
    assert_equal Cron2English.parse("1 2 3 4 5").join(' '),schedule.frequency_in_words
    assert_equal "1 2 3 4 5 BLAH", schedule.cron
  end

  def test_frequency_in_words_with_no_cron
    schedule = ScheduleElement.new
    assert_nil schedule.frequency_in_words
    assert_nil schedule.cron
  end

  def test_frequency_in_words_mangled_cron
    schedule = ScheduleElement.new(cron: "asdfajsd falskdjfasldfj")
    assert_nil schedule.frequency_in_words
    assert_equal "asdfajsd falskdjfasldfj",schedule.cron
  end
end
