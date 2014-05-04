require 'quick_test_helper'
require 'minitest/autorun'
require 'support/fake_resque_data_store'

class ResqueInstanceTest < MiniTest::Test
  def setup
    ResqueInstance.register_instance(name: "test1", resque_data_store: FakeResqueDataStore.new)
    ResqueInstance.register_instance(name: "test2", resque_data_store: FakeResqueDataStore.new)
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

  def test_failed
    assert_equal 10,ResqueInstance.find("test1").failed
  end

  def test_running
    assert_equal 3,ResqueInstance.find("test1").running
  end

  def test_running_too_long
    assert_equal 1,ResqueInstance.find("test1").running_too_long
  end

  def test_running_too_long_explicit_config
    ResqueInstance.register_instance(name: "test3", resque_data_store: FakeResqueDataStore.new, stale_worker_seconds: 30)
    assert_equal 2,ResqueInstance.find("test3").running_too_long
  end

  def test_waiting
    assert_equal 7,ResqueInstance.find("test1").waiting
  end
end
