require 'test_helper'
require 'support/fake_resque_instance'

class WorkersControllerTest < ActionController::TestCase
  setup do
    @worker = Resque::Worker.new("mail")
    @fake_resque_instance = FakeResqueInstance.new(name: "test1",
                                                   workers: [@worker])
    resques = Resques.new([@fake_resque_instance])
    @original_resques = JobsController.resques
    WorkersController.resques = resques
  end

  teardown do
    WorkersController.resques = @original_resques
  end

  test "kill worker" do
    delete :destroy, resque_id: "test1", id: @worker.id
    assert_response 204
    assert_equal [], @fake_resque_instance.workers
  end

end
