# frozen_string_literal: true

require 'redis'
require 'redis/namespace'
require 'resque/data_store'
require_relative 'cached_resque_instance'

# Repository of configured resques.  In general, you want in an initializer:
#
#     RESQUES = Resques.from_environment
#
# And then use `RESQUES` to access the configured resques.
class Resques
  # Parses the environment, yielding each configured instance to the block
  def self.from_environment
    resque_urls = if ENV['RESQUE_BRAIN_INSTANCES'] == 'DERIVE'
                    ENV.keys.map do |env_var_name|
                      ResqueUrl.recognize(env_var_name)
                    end.compact
                  else
                    String(ENV['RESQUE_BRAIN_INSTANCES']).split(/\s*,\s*/).map do |instance_name|
                      ResqueUrl.new(instance_name)
                    end
                  end
    new(resque_urls.map do |resque_url|
      namespace = ENV[resque_url.namespace_env_var.to_s] || :resque
      redis = Redis::Namespace.new(namespace, redis: Redis.new(url: resque_url.url))
      resque_instance = ResqueInstance.new(name: resque_url.resque_name, resque_data_store: Resque::DataStore.new(redis))
      if ENV['RESQUE_BRAIN_CACHE_RESQUE_CALLS'] == 'true'
        Rails.logger.info('Caching of resque calls configured')
        resque_instance = CachedResqueInstance.new(resque_instance)
      end
      resque_instance
    end)
  end

  def initialize(instances)
    @instances = Hash[instances.map do |instance|
      [instance.name, instance]
    end]
  end

  def all
    @instances.values
  end

  def find(name)
    @instances[name]
  end
end
