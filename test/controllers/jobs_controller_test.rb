require 'test_helper'
require 'support/fake_resque_instance'

class JobsControllerTest < ActionController::TestCase
  setup do
    @jobs_running_unsorted = [
      RunningJob.new(
        queue: "pdf",
        payload: {
          class: "GeneratePackInMaterialsJob",
          args: [ 86484, true ],
        },
        started_at: (Time.now.utc - 1.hour),
        worker: "p9e942asfhjsfg",
        too_long: false,
      ),
      RunningJob.new(
        queue: "mail",
        payload: {
          class: "UserWelcomeMailer",
          args: [ 12345 ],
        },
        started_at: Time.now.utc,
        worker: "p9e942asfhjsfg",
        too_long: false,
      ),
    ]
    jobs_waiting = {
      "pdf" => [
        Job.new(
          queue: "pdf",
          payload: { 
            class: "GeneratePackInMaterialsJob",
            args: [123,456] 
          }
        ),
        Job.new(
          queue: "pdf",
          payload: { 
            class: "GeneratePackInMaterialsJob",
            args: [789,123] 
          }
        )
      ],
      "cache" => [
        Job.new(
          queue: "cache",
          payload: { 
            class: "CacheInvalidationJob",
            args: ["foo"] 
          }
        )
      ]
    }
    resques = Resques.new([
      FakeResqueInstance.new(name: "test1",
                             jobs_running: @jobs_running_unsorted,
                             jobs_waiting: jobs_waiting)
    ])
    JobsController.resques = resques
  end

  test "running" do
    get :running, resque_id: "test1", format: :json

    assert_response :success

    result = JSON.parse(response.body)

    assert_equal @jobs_running_unsorted[1].queue                  , result[0]["queue"]
    assert_equal @jobs_running_unsorted[1].started_at.to_i * 1000 , result[0]["startedAt"]
    assert_equal @jobs_running_unsorted[1].too_long               , result[0]["tooLong"]
    assert_equal @jobs_running_unsorted[1].payload[:class]        , result[0]["payload"]["class"]
    assert_equal @jobs_running_unsorted[1].payload[:args]         , result[0]["payload"]["args"]

    assert_equal @jobs_running_unsorted[0].queue                  , result[1]["queue"]
    assert_equal @jobs_running_unsorted[0].started_at.to_i * 1000 , result[1]["startedAt"]
    assert_equal @jobs_running_unsorted[0].too_long               , result[1]["tooLong"]
    assert_equal @jobs_running_unsorted[0].payload[:class]        , result[1]["payload"]["class"]
    assert_equal @jobs_running_unsorted[0].payload[:args]         , result[1]["payload"]["args"]

    assert_equal 2, result.size
  end

  test "waiting" do
    get :waiting, resque_id: "test1", format: :json

    assert_response :success

    result = JSON.parse(response.body)

    assert_equal 2, result.size

    assert_equal 1      , result[0]["jobs"].size
    assert_equal "cache", result[0]["queue"]
    assert_equal "cache", result[0]["jobs"][0]["queue"]
    assert_nil            result[0]["jobs"][0]["worker"]
    assert_nil            result[0]["jobs"][0]["startedAt"]
    refute                result[0]["jobs"][0]["tooLong"]

    assert_equal "CacheInvalidationJob" , result[0]["jobs"][0]["payload"]["class"]
    assert_equal ["foo"]                , result[0]["jobs"][0]["payload"]["args"]

    assert_equal 2    , result[1]["jobs"].size
    assert_equal "pdf", result[1]["queue"]
    assert_equal "pdf", result[1]["jobs"][0]["queue"]
    assert_nil          result[1]["jobs"][0]["worker"]
    assert_nil          result[1]["jobs"][0]["startedAt"]
    refute              result[1]["jobs"][0]["tooLong"]

    assert_equal "GeneratePackInMaterialsJob" , result[1]["jobs"][0]["payload"]["class"]
    assert_equal [123, 456]                   , result[1]["jobs"][0]["payload"]["args"]

    assert_equal "pdf", result[1]["jobs"][1]["queue"]
    assert_nil          result[1]["jobs"][1]["worker"]
    assert_nil          result[1]["jobs"][1]["startedAt"]
    refute              result[1]["jobs"][1]["tooLong"]

    assert_equal "GeneratePackInMaterialsJob" , result[1]["jobs"][1]["payload"]["class"]
    assert_equal [789, 123]                   , result[1]["jobs"][1]["payload"]["args"]


  end
end
