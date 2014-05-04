require 'quick_test_helper'
require 'minitest/autorun'
require 'ostruct'

class ResqueInstanceTest < MiniTest::Test
  def setup
    ResqueInstance.register_instance(name: "test1", resque_data_store: OpenStruct.new)
    ResqueInstance.register_instance(name: "test2", resque_data_store: OpenStruct.new)
  end

  def teardown
    ResqueInstance.unregister_all!
  end

  def test_all
    all = ResqueInstance.all
    assert_equal ["test1","test2"],all.map(&:name).sort
  end

  def test_find_exists
    assert_equal "test1", ResqueInstance.find("test1").name
  end

  def test_find_not_exists
    assert_nil ResqueInstance.find("blah")
  end
end
