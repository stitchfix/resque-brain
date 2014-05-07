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
      raise "WTF" unless resque_instance.failed  == 2
      raise "WTF" unless resque_instance.waiting == 3
      raise "WTF" unless resque_instance.running == 1
    end
  end

  test "shows the summary" do
    visit("/")
    assert page.has_text?("2 Jobs Failed")  , page.html
    assert page.has_text?("3 Jobs Waiting") , page.html
    assert page.has_text?("1 Job Running")  , page.html
    assert page.has_text?("localhost")      , page.html
  end
    

  test "can click through to the failed page of that resque" do
    visit("/")
    click_link "View Failed Jobs"
    assert page.has_text?("2 Failed Jobs")         , page.html
    assert page.has_text?("localhost")             , page.html
    assert page.has_text?("Resque::TermException") , page.html
  end

  test "can click through to the running page of that resque" do
    visit("/")
    click_link "View Running Jobs"
    assert page.has_text?("1 Job Running")  , page.html
    assert page.has_text?("localhost")      , page.html
    assert page.has_text?("RunningTypeJob") , page.html
  end

  test "can click through to the waiting page of that resque" do
    visit("/")
    click_link "View Waiting Jobs"
    assert page.has_text?("3 Jobs Waiting")  , page.html
    assert page.has_text?("localhost")       , page.html
    assert page.has_text?("WaitingTypeJob")  , page.html
  end

  def click_on_link_text(link_text)
    # Capybara requires <a> elements to have an href in order to
    # click on them.  That is terrible.
    find(:xpath,"//a[contains(text(),'#{link_text}')]").click
  end
end
