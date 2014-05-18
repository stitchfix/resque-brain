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
    assert page.all("[title='Retry Job 0']").present?
    assert page.all("[title='Retry Job 9']").present?
    refute page.all("[title='Retry Job 10']").present?
    refute page.has_content?("worker10"), page_assertion_error_message(page)

    first("[title='Page 2 of Results']").click
    sleep 1
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
    assert page.all("[title='Job 1 retried']").present?

    click_link "Waiting Jobs"
    sleep 1
    assert_equal "mail", page.all("tbody tr td")[0].text, page_assertion_error_message(page)
    assert_equal "1", page.all("tbody tr td")[1].text, page_assertion_error_message(page)
  end

  test "clear" do
    visit("/")
    click_link "View Failed Jobs"
    sleep 1

    first("[title='Clear Job 2']").click
    sleep 2
    refute page.has_content?("worker2"), page_assertion_error_message(page)
    assert page.has_content?("worker10"), page_assertion_error_message(page)
  end

  test "clear and retry" do
    visit("/")

    sanity_check do
      click_link "Waiting Jobs"
      refute page.has_selector?("tbody tr td"), page_assertion_error_message(page)
    end

    click_link "Failed Jobs"
    sleep 1

    first("[title='Retry, Then Clear Job 2']").click
    sleep 2
    refute page.has_content?("worker2"), page_assertion_error_message(page)
    assert page.has_content?("worker10"), page_assertion_error_message(page)

    click_link "Waiting Jobs"
    sleep 1
    assert_equal "mail", page.all("tbody tr td")[0].text, page_assertion_error_message(page)
    assert_equal "1", page.all("tbody tr td")[1].text, page_assertion_error_message(page)
  end

  test "retry all" do
    visit("/")

    click_link "Failed Jobs"
    sleep 1

    first("[title='Retry All']").click
    sleep 2
    (0..9).each do |job_id|
      assert page.all("[title='Job #{job_id} retried']").present?
    end

    click_link "Waiting Jobs"
    sleep 1
    assert_equal "mail", page.all("tbody tr td")[0].text, page_assertion_error_message(page)
    assert_equal "21", page.all("tbody tr td")[1].text, page_assertion_error_message(page)
  end

  test "clear all" do
    visit("/")

    click_link "Failed Jobs"
    sleep 1

    first("[title='Clear All']").click
    sleep 2
    assert page.has_content?("0 Jobs Failed"), page_assertion_error_message(page)
  end

  test "retry and clear all" do
    visit("/")

    click_link "Failed Jobs"
    sleep 1

    first("[title='Retry, Then Clear All']").click
    sleep 2
    assert page.has_content?("0 Jobs Failed")

    click_link "Waiting Jobs"
    sleep 1
    assert_equal "mail", page.all("tbody tr td")[0].text, page_assertion_error_message(page)
    assert_equal "21", page.all("tbody tr td")[1].text, page_assertion_error_message(page)
  end
end
