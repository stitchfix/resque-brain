require 'quick_test_helper'
require 'minitest/autorun'
require 'support/fake_resque_data_store'

class ResqueInstanceTest < MiniTest::Test
  def setup
    ResqueInstance.unregister_all!
    ResqueInstance.register_instance(name: "test1", resque_data_store: FakeResqueDataStore.new)
    ResqueInstance.register_instance(name: "test2", resque_data_store: FakeResqueDataStore.new)
  end

  def teardown
    ResqueInstance.unregister_all!
    ENV["RESQUE_BRAIN_INSTANCES"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = nil
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
    assert_equal 4,ResqueInstance.find("test1").running
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

  def test_from_environment
    ResqueInstance.unregister_all!
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://whatever:supersecret@localhost:1234"
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = "redis://whatever:megasecret@10.0.0.1:4567"

    ResqueInstance.init_from_env!

    assert_equal 2, ResqueInstance.all.size
    refute_nil ResqueInstance.find("env1")
    refute_nil ResqueInstance.find("env2")

    redis_namespace = ResqueInstance.find("env1").resque_data_store.instance_variable_get("@redis")
    assert       redis_namespace.kind_of?(Redis::Namespace)
    assert_equal :resque       , redis_namespace.namespace
    assert_equal 1234          , redis_namespace.redis.client.port
    assert_equal "localhost"   , redis_namespace.redis.client.host
    assert_equal "supersecret" , redis_namespace.redis.client.password

    redis_namespace = ResqueInstance.find("env2").resque_data_store.instance_variable_get("@redis")
    assert       redis_namespace.kind_of?(Redis::Namespace)
    assert_equal :resque       , redis_namespace.namespace
    assert_equal 4567          , redis_namespace.redis.client.port
    assert_equal "10.0.0.1"    , redis_namespace.redis.client.host
    assert_equal "megasecret"  , redis_namespace.redis.client.password
  end

  def test_from_environment_missing_config
    ResqueInstance.unregister_all!
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://localhost:1234"
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = nil

    assert_raises(ResqueInstance::MissingResqueConfigurationError) do
      ResqueInstance.init_from_env!
    end
  end

  def test_from_environment_missing_instance_list
    ResqueInstance.unregister_all!
    ENV["RESQUE_BRAIN_INSTANCES"] = nil

    assert_raises(ResqueInstance::MissingResqueConfigurationError) do
      ResqueInstance.init_from_env!
    end
  end
end
