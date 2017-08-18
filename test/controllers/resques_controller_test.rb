# frozen_string_literal: true

require 'test_helper'
require 'support/fake_resque_data_store'

class ResquesControllerTest < ActionController::TestCase
  setup do
    @resques = Resques.new([
                             ResqueInstance.new(name: 'test2', resque_data_store: FakeResqueDataStore.new),
                             ResqueInstance.new(name: 'Test1', resque_data_store: FakeResqueDataStore.new)
                           ])
    @original_resques = ResquesController.resques
    ResquesController.resques = @resques
  end

  teardown do
    ResquesController.resques = @original_resques
  end

  test 'index' do
    get :index, format: :json

    assert_response :success

    result = JSON.parse(response.body)
    assert_equal result[0]['name'], 'Test1'
    assert_equal result[1]['name'], 'test2'
    assert_equal 2, result.size
  end

  test 'show with nonexistent resque' do
    get :show, params: { format: :json, id: 'blah' }
    assert_response :not_found
  end

  test 'show with real resque' do
    get :show, params: { format: :json, id: 'Test1' }

    assert_response :success

    resque_instance = @resques.find('Test1')

    result = JSON.parse(response.body)

    assert_equal resque_instance.name, result['name']
    assert_equal resque_instance.running, result['running']
    assert_equal resque_instance.running_too_long, result['runningTooLong']
    assert_equal resque_instance.failed, result['failed']
    assert_equal resque_instance.waiting, result['waiting']
  end
end
