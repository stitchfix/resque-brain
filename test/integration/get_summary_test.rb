require 'integration_test_helper'

class GetSummaryTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
    @redis = Redis::Namespace.new(:resque,Redis.new)
    @redis.flushall
    @resque_data_store = Resque::DataStore.new(@redis)
    # 3 jobs waiting
    3.times do |i|
      @resque_data_store.push_to_queue(:mail,Resque.encode({ class: "WaitingTypeJob", args: [i,2,3]}))
    end

    # 1 job running
    worker = Resque::Worker.new(:mail)
    @resque_data_store.register_worker(worker)
    @resque_data_store.set_worker_payload(
      worker,
      Resque.encode(
        :queue   => :mail,
        :run_at  => Time.now.utc.iso8601,
        :payload => { class: "RunningTypeJob", args: [4,5,6] }
      )
    )

    # 2 jobs failed
    2.times do |i|
      @resque_data_store.push_to_failed_queue(Resque.encode(
        failed_at: Time.now.utc.iso8601,
        payload: { class: "Baz", args: [ i ]},
        exception: "Resque::TermException",
        error: "SIGTERM",
        backtrace: [ "foo","bar","blah"],
        queue: "mail",
        worker: "worker#{i}",
      ))
    end
    sanity_check do
      resque_instance = ResqueInstance.new(resque_data_store: @resque_data_store)
      raise "Got #{resque_instance.failed} instead of 2 failing jobs"  unless resque_instance.jobs_failed.size  == 2
      raise "Got #{resque_instance.waiting} instead of 3 waiting jobs" unless resque_instance.waiting == 3
      raise "Got #{resque_instance.running} instead of 1 running job"  unless resque_instance.running == 1
    end
  end

  test "shows the summary" do
    visit("/")
    assert page.has_text?("2 Jobs Failed")  , page_assertion_error_message(page)
    assert page.has_text?("3 Jobs Waiting") , page_assertion_error_message(page)
    assert page.has_text?("1 Job Running")  , page_assertion_error_message(page)
    assert page.has_text?("localhost")      , page_assertion_error_message(page)
  end
    

  test "can click through to the failed page of that resque" do
    visit("/")
    click_link "View Failed Jobs"
    assert page.has_text?("2 Jobs Failed")         , page_assertion_error_message(page)
    assert page.has_text?("localhost")             , page_assertion_error_message(page)
    assert page.has_text?("Resque::TermException") , page_assertion_error_message(page)
    assert page.has_text?("Baz")                   , page_assertion_error_message(page)
  end

  test "can click through to the running page of that resque" do
    visit("/")
    click_link "View Running Jobs"
    assert page.has_text?("1 Job Running")  , page_assertion_error_message(page)
    assert page.has_text?("localhost")      , page_assertion_error_message(page)
    assert page.has_text?("RunningTypeJob") , page_assertion_error_message(page)
  end

  test "can click through to the waiting page of that resque" do
    visit("/")
    click_link "View Waiting Jobs"
    assert page.has_text?("3 Jobs Waiting") , page_assertion_error_message(page)
    assert page.has_text?("localhost")      , page_assertion_error_message(page)
    assert page.has_text?("mail")           , page_assertion_error_message(page)
  end
end
