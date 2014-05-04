class ResqueInstance
  @@instances = {}
  def self.all
    @@instances["default"] = ResqueInstance.new(name: "default", resque_data_store: Resque::DataStore.new(Redis.new))
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
      Time.now - worker_info["run_at"] >= @stale_worker_seconds
    }.size
  end

  def waiting
    @resque_data_store.queue_names.reduce(0) { |current_sum,queue_name|
      current_sum + @resque_data_store.queue_size(queue_name)
    }
  end
end
