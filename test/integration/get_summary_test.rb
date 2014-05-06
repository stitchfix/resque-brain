require 'integration_test_helper'

class GetSummaryTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
    @redis = Redis::Namespace.new(:resque,Redis.new)
    @redis.flushall
    @resque_data_store = Resque::DataStore.new(@redis)
  end
  test "summary page with no activity" do
    visit("/")
    assert page.has_content?("0 Jobs Failed"), page.html
    assert page.has_content?("0 Jobs Waiting"), page.html
    assert page.has_content?("0 Jobs Running"), page.html
    assert page.has_content?("localhost"), page.html
  end

  test "summary page with jobs waiting, failed, and running" do
    # 3 jobs waiting
    3.times do |i|
      @resque_data_store.push_to_queue(:mail,Resque.encode({ class: "Foo", args: [i,2,3]}))
    end

    # 1 job running
    worker = Resque::Worker.new(:mail)
    @resque_data_store.register_worker(worker)
    @resque_data_store.set_worker_payload(
      worker,
      Resque.encode(
        :queue   => :mail,
        :run_at  => Time.now.utc.iso8601,
        :payload => { class: "Bar", args: [4,5,6] }
      )
    )

    # 2 jobs failed
    2.times do |i|
      @resque_data_store.push_to_failed_queue(Resque.encode({ class: "Baz", args: [ i ]}))
    end

    sanity_check do
      resque_instance = ResqueInstance.new(resque_data_store: @resque_data_store)
      raise "WTF" unless resque_instance.failed  == 2
      raise "WTF" unless resque_instance.waiting == 3
      raise "WTF" unless resque_instance.running == 1
    end

    visit("/")
    assert page.has_text?("2 Jobs Failed")  , page.html
    assert page.has_text?("3 Jobs Waiting") , page.html
    assert page.has_text?("1 Job Running")  , page.html
    assert page.has_text?("localhost")      , page.html
  end
end
