require 'test_helper'
require 'support/fake_resque_instance'

class SchedulesControllerTest < ActionController::TestCase

  setup do
    @schedule = [
      Schedule.new(name: "foo", klass: "BarJob", queue: "foo_queue", description: "Some awesome job", args: nil, cron_expression: "3 * * * *"),
      Schedule.new(name: "bar", klass: "BazJob", queue: "bar_queue", description: "Some crappy job", args: [1,"foo",true], cron_expression: "*/3 * * * *"),
      Schedule.new(name: "baz", klass: "BarJob", queue: "foo_queue", description: "Some awesome job", args: ["blah"], cron_expression: "3 1 * * *"),
    ]
    @resque_instance  = FakeResqueInstance.new(name: "test1", schedule: @schedule)
    @original_resques = SchedulesController.resques

    SchedulesController.resques = Resques.new([@resque_instance])
  end

  teardown do
    SchedulesController.resques = @original_resques
  end

  test "show" do
    get :show, resque_id: "test1", format: :json

    assert_response :success

    result = JSON.parse(response.body)

    @schedule.each_with_index do |schedule_element,i|
      assert_equal schedule_element.name               , result[i]["name"]
      assert_equal schedule_element.args               , result[i]["args"]
      assert_equal schedule_element.klass              , result[i]["klass"]
      assert_equal schedule_element.queue              , result[i]["queue"]
      assert_equal schedule_element.description        , result[i]["description"]
      assert_equal schedule_element.every              , result[i]["every"]
      assert_equal schedule_element.cron               , result[i]["cron"]
      assert_equal schedule_element.frequency_in_words , result[i]["frequencyEnglish"]
    end
  end
end
