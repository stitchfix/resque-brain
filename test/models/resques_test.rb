require 'quick_test_helper'
require 'minitest/autorun'
require 'support/fake_resque_data_store'
require 'support/fake_logger'
rails_require 'models/resque_url'
rails_require 'models/missing_resque_configuration_error'
rails_require 'models/resques'
rails_require 'models/resque_instance'
unless defined?(Rails)
  module Rails
    def self.logger
      FakeLogger.new
    end
  end
end

class ResquesTest < MiniTest::Test
  def teardown
    ENV["RESQUE_BRAIN_INSTANCES"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = nil
    ENV["ENV2_RESQUE_REDIS_URL"] = nil
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
    ENV["RESQUE_BRAIN_CACHE_RESQUE_CALLS"] = nil
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2,env3"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://whatever:supersecret@localhost:1234"
    ENV["ENV2_RESQUE_REDIS_URL"] = "redis://whatever:megasecret@10.0.0.1:4567"
    ENV["ENV3_REDIS_URL"] = "redis://whatever:l33secret@10.0.1.1:4568"
    ENV["ENV3_NAMESPACE"] = "test"

    resques = Resques.from_environment

    assert_equal 3, resques.all.size
    refute_nil resques.find("env1")
    refute_nil resques.find("env2")
    refute_nil resques.find("env3")

    refute_equal CachedResqueInstance,resques.find("env1").class
    refute_equal CachedResqueInstance,resques.find("env2").class
    refute_equal CachedResqueInstance,resques.find("env2").class

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

    redis_namespace = resques.find("env3").resque_data_store.instance_variable_get("@redis")
    assert       redis_namespace.kind_of?(Redis::Namespace)
    assert_equal "test"        , redis_namespace.namespace
    assert_equal 4568          , redis_namespace.redis.client.port
    assert_equal "10.0.1.1"    , redis_namespace.redis.client.host
    assert_equal "l33secret"   , redis_namespace.redis.client.password
  end

  def test_from_environment_using_cache
    ENV["RESQUE_BRAIN_CACHE_RESQUE_CALLS"] = "true"
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2,env3"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://whatever:supersecret@localhost:1234"
    ENV["ENV2_RESQUE_REDIS_URL"] = "redis://whatever:megasecret@10.0.0.1:4567"
    ENV["ENV3_REDIS_URL"] = "redis://whatever:l33secret@10.0.1.1:4568"
    ENV["ENV3_NAMESPACE"] = "test"

    resques = Resques.from_environment

    assert_equal 3, resques.all.size
    refute_nil resques.find("env1")
    refute_nil resques.find("env2")
    refute_nil resques.find("env3")

    assert_equal CachedResqueInstance,resques.find("env1").class
    assert_equal CachedResqueInstance,resques.find("env2").class
    assert_equal CachedResqueInstance,resques.find("env2").class
  end

  def test_from_environment_missing_config
    ENV["RESQUE_BRAIN_INSTANCES"] = "env1,env2"
    ENV["RESQUE_BRAIN_INSTANCES_env1"] = "redis://localhost:1234"
    ENV["ENV2_RESQUE_REDIS_URL"] = nil

    exception = assert_raises(MissingResqueConfigurationError) do
      Resques.from_environment
    end
    assert_match /env2/, exception.message
    assert_match /RESQUE_BRAIN_INSTANCES_env2/, exception.message
    assert_match /ENV2_RESQUE_REDIS_URL/, exception.message
  end

private

  def create_test_resques
    Resques.new([
      ResqueInstance.new(name: "test1", resque_data_store: FakeResqueDataStore.new),
      ResqueInstance.new(name: "test2", resque_data_store: FakeResqueDataStore.new),
    ])
  end

end
