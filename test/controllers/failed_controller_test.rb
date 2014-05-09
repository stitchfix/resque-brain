require 'test_helper'
require 'support/fake_resque_instance'

class FailedControllerTest < ActionController::TestCase
  setup do
    @jobs_failed_unsorted = [
      FailedJob.new(
        failed_at: Time.now.utc - 3.hours,
        payload: {
          class: "SomeFailingJob",
          args: [500145, 1114130]
        },
        exception: "Resque::TermException",
        error: "SIGTERM",
        backtrace: [
          "/app/app/services/blah_whatever.rb:57:in `block in whatever!'",
          "/app/app/services/blah_whatever.rb:77:in `call'",
          "/app/app/services/blah_whatever.rb:77:in `with_whatever'",
          "/app/app/services/blah_whatever.rb:52:in `whatever!'",
          "/app/app/services/blah_whatever.rb:11:in `whatever_items_from_bleorgh'",
          "/app/lib/exceptions/exception_augmenter.rb:10:in `call'",
          "/app/lib/exceptions/exception_augmenter.rb:10:in `augment_all_exceptions_with'",
          "/app/app/jobs/concerns/whatevering_job.rb:6:in `augment_exceptions_with_remediation_help'",
          "/app/app/jobs/whatever_inconsistent_blagh_job.rb:8:in `perform'"
        ],
       worker: "some_worker_id",
       queue: "mail"
      ),
      FailedJob.new(
        failed_at: Time.now.utc,
        payload: {
          class: "SomeOtherFailingJob",
          args: ["blah"]
        },
        exception: "KeyError",
        error: "No Such key 'foobar'",
        backtrace: [
          "/app/app/services/blah_whatever.rb:57:in `block in whatever!'",
          "/app/app/services/blah_whatever.rb:77:in `call'",
          "/app/app/services/blah_whatever.rb:77:in `with_whatever'",
          "/app/app/jobs/concerns/whatevering_job.rb:6:in `augment_exceptions_with_remediation_help'",
          "/app/app/jobs/whatever_inconsistent_blagh_job.rb:8:in `perform'"
        ],
       worker: "some_other_worker_id",
       queue: "cache"
      )
    ]
    resques = Resques.new([
      FakeResqueInstance.new(name: "test1",
                             jobs_failed: @jobs_failed_unsorted)
    ])
    FailedController.resques = resques
  end

  test "index" do
    get :index, resque_id: "test1", format: :json

    assert_response :success

    result = JSON.parse(response.body)

    assert_equal 2, result.size

    assert_equal @jobs_failed_unsorted[1].exception             , result[0]["exception"]
    assert_equal @jobs_failed_unsorted[1].queue                 , result[0]["queue"]
    assert_equal @jobs_failed_unsorted[1].worker                , result[0]["worker"]
    assert_equal @jobs_failed_unsorted[1].backtrace.size        , result[0]["backtrace"].size
    assert_equal @jobs_failed_unsorted[1].failed_at.to_i * 1000 , result[0]["failedAt"]

    assert_equal @jobs_failed_unsorted[0].exception             , result[1]["exception"]
    assert_equal @jobs_failed_unsorted[0].queue                 , result[1]["queue"]
    assert_equal @jobs_failed_unsorted[0].worker                , result[1]["worker"]
    assert_equal @jobs_failed_unsorted[0].backtrace.size        , result[1]["backtrace"].size
    assert_equal @jobs_failed_unsorted[0].failed_at.to_i * 1000 , result[1]["failedAt"]
  end

end
