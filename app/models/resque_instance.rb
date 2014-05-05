require 'redis'
require 'redis/namespace'
require 'resque/data_store'

class ResqueInstance
  class MissingResqueConfigurationError < StandardError
  end

  # Parses the environment, yielding each configured instance to the block
  def self.init_from_env!(&block)
    ENV.fetch("RESQUE_BRAIN_INSTANCES").split(/\s*,\s*/).each do |instance_name|
      uri   = URI.parse(ENV.fetch("RESQUE_BRAIN_INSTANCES_#{instance_name}"))
      redis = Redis::Namespace.new(:resque,redis: Redis.new(host: uri.host, port: uri.port, password: uri.password))
      register_instance(name: instance_name, resque_data_store: Resque::DataStore.new(redis))
    end
  rescue KeyError => ex
    raise MissingResqueConfigurationError,ex.message
  end

  @@instances = {}
  def self.all
    @@instances.values
  end

  def self.register_instance(opts)
    @@instances[opts[:name]] = self.new(opts)
  end

  def self.unregister_all!
    @@instances = {}
  end

  def self.find(name)
    @@instances[name]
  end

  attr_reader :name,
              :resque_data_store

  def initialize(config={})

    @name                 = config[:name]
    @resque_data_store    = config[:resque_data_store]
    @stale_worker_seconds = config[:stale_worker_seconds] || 3600

  end

  def failed
    @resque_data_store.num_failed
  end

  def running
    worker_ids = Array(@resque_data_store.worker_ids)
    return 0 if worker_ids.empty?
    @resque_data_store.workers_map(worker_ids).reject { |id,worker_info| worker_info.nil? }.size
  end

  def running_too_long
    worker_ids = Array(@resque_data_store.worker_ids)
    return 0 if worker_ids.empty?
    @resque_data_store.workers_map(worker_ids).reject { |id,worker_info| 
      worker_info.nil? 
    }.select { |_,worker_info|
      Time.now - Time.parse(worker_info["run_at"]) >= @stale_worker_seconds rescue false
    }.size
  end

  def waiting
    @resque_data_store.queue_names.reduce(0) { |current_sum,queue_name|
      current_sum + @resque_data_store.queue_size(queue_name)
    }
  end
end
