require 'integration_test_helper'

class FailedQueueTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
    @redis = Redis::Namespace.new(:resque,Redis.new)
    @redis.flushall
    @resque_data_store = Resque::DataStore.new(@redis)

    21.times do |i|
      @resque_data_store.push_to_failed_queue(Resque.encode(
        failed_at: (Time.now.utc - (i * 1000)).iso8601,
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
      raise "Got #{resque_instance.failed} instead of 21 failing jobs"  unless resque_instance.jobs_failed.size == 21
    end
  end

  test "pagination" do

    visit("/")
    click_link "View Failed Jobs"
    sleep 1

    assert page.has_text?("21 Jobs Failed"), page_assertion_error_message(page)

    assert_equal 10, page.all("article.failed-job").count
    assert page.has_content?("worker0"), page_assertion_error_message(page)
    assert page.has_content?("worker1"), page_assertion_error_message(page)
    refute page.all("[title='Retry Job 0']").empty?
    refute page.all("[title='Retry Job 9']").empty?
    assert page.all("[title='Retry Job 10']").empty?
    refute page.has_content?("worker10"), page_assertion_error_message(page)

    first("[title='Page 2 of Results']").click
    assert_equal 10, page.all("article.failed-job").count, page_assertion_error_message(page)
    refute page.has_content?("worker0"), page_assertion_error_message(page)
    refute page.has_content?("worker2"), page_assertion_error_message(page)
    refute page.all("[title='Retry Job 10']").empty?, page.html
    assert page.has_content?("worker10"), page_assertion_error_message(page)
    assert page.has_content?("worker19"), page_assertion_error_message(page)
    refute page.has_content?("worker20"), page_assertion_error_message(page)
  end

  test "retry" do
    visit("/")
    click_link "View Failed Jobs"
    sleep 1

    assert page.all("[title='Job 1 retried']").empty?
    first("[title='Retry Job 1']").click
    assert page.has_content?("worker1"), page_assertion_error_message(page)
    refute page.all("[title='Job 1 retried']").empty?
  end
end
