require 'test_helper'
require 'support/fake_resque_data_store'

class FakeResqueInstance
  attr_reader :jobs_running
  attr_reader :name
  def initialize(name,jobs_running)
    @name = name
    @jobs_running = jobs_running
  end
end
class JobsControllerTest < ActionController::TestCase
  setup do
    @jobs_running_unsorted = [
      Job.new(
        queue: "pdf",
        payload: {
          class: "GeneratePackInMaterialsJob",
          args: [ 86484, true ],
        },
        started_at: (Time.now.utc - 1.hour).iso8601,
        worker: "p9e942asfhjsfg",
        too_long: false,
      ),
      Job.new(
        queue: "mail",
        payload: {
          class: "UserWelcomeMailer",
          args: [ 12345 ],
        },
        started_at: Time.now.utc.iso8601,
        worker: "p9e942asfhjsfg",
        too_long: false,
      ),
    ]
    resques = Resques.new([
      FakeResqueInstance.new("test1",@jobs_running_unsorted)
    ])
    JobsController.resques = resques
  end

  test "waiting" do
    get :waiting, resque_id: "test1", format: :json

    assert_response :success

    result = JSON.parse(response.body)

    assert_equal @jobs_running_unsorted[1][:queue]                  , result[0]["queue"]
    assert_equal @jobs_running_unsorted[1][:started_at].to_i * 1000 , result[0]["startedAt"]
    assert_equal @jobs_running_unsorted[1][:too_long]               , result[0]["tooLong"]

    assert_equal @jobs_running_unsorted[0][:queue]                  , result[1]["queue"]
    assert_equal @jobs_running_unsorted[0][:started_at].to_i * 1000 , result[1]["startedAt"]
    assert_equal @jobs_running_unsorted[0][:too_long]               , result[1]["tooLong"]

    assert_equal 2, result.size
  end
end
