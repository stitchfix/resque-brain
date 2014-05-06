require 'quick_test_helper'
require 'minitest/autorun'
require 'support/fake_resque_data_store'
rails_require 'models/resques'
rails_require 'models/resque_instance'

class ResquesTest < MiniTest::Test
  def teardown
    ENV["RESQUE_BRAIN_INSTANCES"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = nil
  end

  def test_all
    all = create_test_resques.all
    assert_equal ["test1","test2"],all.map(&:name).sort
  end

  def test_find_exists
    assert_equal "test1", create_test_resques.find("test1").name
  end

  def test_find_not_exists
    assert_nil create_test_resques.find("blah")
  end

  def test_from_environment
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://whatever:supersecret@localhost:1234"
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = "redis://whatever:megasecret@10.0.0.1:4567"

    resques = Resques.from_environment

    assert_equal 2, resques.all.size
    refute_nil resques.find("env1")
    refute_nil resques.find("env2")

    redis_namespace = resques.find("env1").resque_data_store.instance_variable_get("@redis")
    assert       redis_namespace.kind_of?(Redis::Namespace)
    assert_equal :resque       , redis_namespace.namespace
    assert_equal 1234          , redis_namespace.redis.client.port
    assert_equal "localhost"   , redis_namespace.redis.client.host
    assert_equal "supersecret" , redis_namespace.redis.client.password

    redis_namespace = resques.find("env2").resque_data_store.instance_variable_get("@redis")
    assert       redis_namespace.kind_of?(Redis::Namespace)
    assert_equal :resque       , redis_namespace.namespace
    assert_equal 4567          , redis_namespace.redis.client.port
    assert_equal "10.0.0.1"    , redis_namespace.redis.client.host
    assert_equal "megasecret"  , redis_namespace.redis.client.password
  end

  def test_from_environment_missing_config
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://localhost:1234"
    ENV["RESQUE_BRAIN_INSTANCES_env2"] = nil

    assert_raises(Resques::MissingResqueConfigurationError) do
      Resques.from_environment
    end
  end

  def test_from_environment_missing_instance_list
    ENV["RESQUE_BRAIN_INSTANCES"] = nil

    assert_raises(Resques::MissingResqueConfigurationError) do
      Resques.from_environment
    end
  end

private

  def create_test_resques
    Resques.new([
      ResqueInstance.new(name: "test1", resque_data_store: FakeResqueDataStore.new),
      ResqueInstance.new(name: "test2", resque_data_store: FakeResqueDataStore.new),
    ])
  end

end
