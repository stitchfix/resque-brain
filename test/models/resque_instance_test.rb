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

  def test_from_environment
    ResqueInstance.unregister_all!
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://localhost:1234"
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = "redis://10.0.0.1:4567"

    parsed_redises = { }
    ResqueInstance.init_from_env! do |instance_name,uri|
      parsed_redises[instance_name] = {
        port: uri.port,
        host: uri.host
      }
      {
        name: instance_name,
        resque_data_store: FakeResqueDataStore.new
      }
    end

    assert_equal 2, ResqueInstance.all.size
    refute_nil ResqueInstance.find("env1")
    refute_nil ResqueInstance.find("env2")

    assert_equal 2, parsed_redises.size
    assert_equal 1234, parsed_redises["env1"][:port]
    assert_equal 4567, parsed_redises["env2"][:port]
    assert_equal "localhost", parsed_redises["env1"][:host]
    assert_equal "10.0.0.1", parsed_redises["env2"][:host]
  end

  def test_from_environment_missing_config
    ResqueInstance.unregister_all!
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://localhost:1234"
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = nil

    assert_raises(ResqueInstance::MissingResqueConfigurationError) do
      ResqueInstance.init_from_env! do |instance_name,uri|
        { 
          name: instance_name,
          resque_data_store: FakeResqueDataStore.new
        }
      end
    end
  end

  def test_data_store_creation
    resque_data_store = ResqueInstance.create_data_store(URI.parse("redis://10.0.0.1:6378"))

    redis_namespace = resque_data_store.instance_variable_get("@redis")

    assert       redis_namespace.kind_of?(Redis::Namespace)
    assert_equal :resque    , redis_namespace.namespace
    assert_equal 6378       , redis_namespace.redis.client.port
    assert_equal "10.0.0.1" , redis_namespace.redis.client.host
  end
end
