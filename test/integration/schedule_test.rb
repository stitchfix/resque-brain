require 'integration_test_helper'

class ScheduleTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
    @redis = Redis::Namespace.new(:resque,redis: Redis.new)
    @redis.redis.flushall

    @schedule = [
      ScheduleElement.new(name: "foo", klass: "BarJob", queue: "foo_queue", description: "Some awesome job", args: nil, cron_expression: "3 * * * *"),
      ScheduleElement.new(name: "bar", klass: "BazJob", queue: "bar_queue", description: "Some crappy job", args: [1,"foo",true], cron_expression: "*/3 * * * *"),
      ScheduleElement.new(name: "baz", klass: "BarJob", queue: "foo_queue", description: "Some awesome job", args: ["blah"], cron_expression: "3 1 * * *"),
    ]

    @schedule.each do |schedule_element|
      @redis.pipelined do
        @redis.hset("schedules",
                    schedule_element.name,
                    {
                            class: schedule_element.klass,
                            queue: schedule_element.queue,
                      description: schedule_element.description,
                             args: schedule_element.args,
                             cron: schedule_element.cron_expression
                    }.to_json)
      end
    end
  end

  test "shows the schedule" do

    visit("/")
    click_link "View Failed Jobs"
    sleep 1
    click_link "Schedule"
    sleep 1

    assert page.has_text?("Schedule"), page_assertion_error_message(page)

    assert_equal @schedule.size, page.all(".schedule .list-group-item").count
    @schedule.each do |schedule_element|
      assert page.has_content?(schedule_element.name)               , page_assertion_error_message(page)
      assert page.has_content?(schedule_element.description)        , page_assertion_error_message(page)
      assert page.has_content?(schedule_element.frequency_in_words) , page_assertion_error_message(page)
      assert page.has_content?(schedule_element.cron)               , page_assertion_error_message(page)
    end
  end

  test "can queue the job manually" do
    visit("/")
    click_link "View Failed Jobs"
    sleep 1
    click_link "Schedule"
    sleep 1

    first("[title='Queue Job #{@schedule[1].name}']").click
    sleep 1

    # Takes us to the running jobs page
    assert_equal "Queue", page.all("thead tr th")[0].text, page_assertion_error_message(page)

    # Since resque's not running, click over to waiting jobs and see it sitting there
    click_link "Waiting Jobs"
    sleep 1
    assert_equal @schedule[1].queue , page.all("tbody tr td")[0].text , page_assertion_error_message(page)
    assert_equal "1"                , page.all("tbody tr td")[1].text , page_assertion_error_message(page)
  end

end
