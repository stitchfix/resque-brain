require 'quick_test_helper'
require 'minitest/autorun'
require 'support/fake_resque_data_store'
rails_require 'models/resque_instance'

class ResqueInstanceTest < MiniTest::Test
  def test_failed
    assert_equal 10,create_test_instance.failed
  end

  def test_running
    assert_equal 4,create_test_instance.running
  end

  def test_running_too_long
    assert_equal 1,create_test_instance.running_too_long
  end

  def test_running_too_long_explicit_config
    resque_instance = ResqueInstance.new(name: "test3", resque_data_store: FakeResqueDataStore.new, stale_worker_seconds: 30)
    assert_equal 2,resque_instance.running_too_long
  end

  def test_waiting
    assert_equal 7,create_test_instance.waiting
  end

private

  def create_test_instance
    ResqueInstance.new(name: "whatever", resque_data_store: FakeResqueDataStore.new)
  end
end
