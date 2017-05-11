require 'redis'
require 'redis/namespace'
require 'resque/data_store'

# Repository of configured resques.  In general, you want in an initializer:
#
#     RESQUES = Resques.from_environment
#
# And then use `RESQUES` to access the configured resques.
class Resques
  # Parses the environment, yielding each configured instance to the block
  def self.from_environment
    namespace = ENV['#{instance_name}_RESQUE_REDIS_URL'] || :resque
    self.new(String(ENV["RESQUE_BRAIN_INSTANCES"]).split(/\s*,\s*/).map { |instance_name|
      namespace = ENV['#{instance_name.upcase.gsub(/-/, "_")}_RESQUE_REDIS_URL'] || :resque
      redis = Redis::Namespace.new(namespace,redis: Redis.new(url: ResqueUrl.new(instance_name).url))
      ResqueInstance.new(name: instance_name, resque_data_store: Resque::DataStore.new(redis))
    })
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
