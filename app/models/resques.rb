require 'redis'
require 'redis/namespace'
require 'resque/data_store'

class Resques
  class MissingResqueConfigurationError < StandardError
  end

  # Parses the environment, yielding each configured instance to the block
  def self.from_environment
    self.new(String(ENV["RESQUE_BRAIN_INSTANCES"]).split(/\s*,\s*/).map { |instance_name|
      uri   = URI.parse(ENV.fetch("RESQUE_BRAIN_INSTANCES_#{instance_name}"))
      redis = Redis::Namespace.new(:resque,redis: Redis.new(host: uri.host, port: uri.port, password: uri.password))
      ResqueInstance.new(name: instance_name, resque_data_store: Resque::DataStore.new(redis))
    })
  rescue KeyError => ex
    raise MissingResqueConfigurationError,ex.message
  end

  def initialize(instances)
    @instances = Hash[instances.map { |instance|
      [instance.name,instance]
    }]
  end

  def all
    @instances.values
  end

  def find(name)
    @instances[name]
  end
end
