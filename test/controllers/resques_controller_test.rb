require 'test_helper'

class ResquesControllerTest < ActionController::TestCase
  setup do
    ResqueInstance.register_instance(name: "test1")
    ResqueInstance.register_instance(name: "test2")
  end
  test "should get index" do
    get :index, format: :json
    assert_response :success

    result = JSON.parse(response.body)
    assert result.include?("name" => "test1")
    assert result.include?("name" => "test2")
    assert_equal 2, result.size
  end

  test "should get show" do
    get :show, format: :json
    assert_response :success
  end

end
