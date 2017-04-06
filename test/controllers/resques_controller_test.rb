require 'test_helper'
require 'mocha/setup'
require 'support/fake_resque_data_store'

class ResquesControllerTest < ActionController::TestCase
  setup do
    @resques = Resques.new([
      ResqueInstance.new(name: "test2", resque_data_store: FakeResqueDataStore.new),
      ResqueInstance.new(name: "Test1", resque_data_store: FakeResqueDataStore.new),
    ])
    @original_resques = ResquesController.resques
    ResquesController.resques = @resques
  end

  teardown do
    ResquesController.resques = @original_resques
  end

  test "index" do
    get :index, format: :json

    assert_response :success

    result = JSON.parse(response.body)
    assert_equal result[0]["name"],"Test1"
    assert_equal result[1]["name"],"test2"
    assert_equal result[1]["running"],4
    assert_equal 2, result.size
  end

  test "a redis connection is timing out, it returns 0 for its running value" do
    @resques.all.first.resque_data_store.expects(:workers_map).at_least(1).raises(Redis::TimeoutError)
    get :index, format: :json
    result = JSON.parse(response.body)
    assert_equal result[0]["name"],"Test1"
    assert_equal result[1]["name"],"test2"
    assert_equal result[1]["running"],0
    assert_equal 2, result.size
  end

  test "show with nonexistent resque" do
    get :show, format: :json, id: "blah"
    assert_response :not_found
  end

  test "show with real resque" do
    get :show, format: :json, id: "Test1"

    assert_response :success

    resque_instance = @resques.find("Test1")

    result = JSON.parse(response.body)

    assert_equal resque_instance.name,result["name"]
    assert_equal resque_instance.running,result["running"]
    assert_equal resque_instance.running_too_long,result["runningTooLong"]
    assert_equal resque_instance.failed,result["failed"]
    assert_equal resque_instance.waiting,result["waiting"]
  end

end
