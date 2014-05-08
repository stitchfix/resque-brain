class ResqueInstance
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
    workers_map(worker_ids).reject { |id,worker_info| worker_info.nil? }.size
  end

  def running_too_long
    worker_ids = Array(@resque_data_store.worker_ids)
    return 0 if worker_ids.empty?
    workers_map(worker_ids).reject { |id,worker_info| 
      worker_info.nil? 
    }.select { |_,worker_info|
      WorkerStartTime.new(worker_info,@stale_worker_seconds).too_long?
    }.size
  end

  def waiting
    @resque_data_store.queue_names.reduce(0) { |current_sum,queue_name|
      current_sum + @resque_data_store.queue_size(queue_name)
    }
  end

  def jobs_running
    worker_ids = Array(@resque_data_store.worker_ids)
    return [] if worker_ids.empty?
    workers_map(worker_ids).reject { |_,worker_info| worker_info.nil?  }.map { |id,worker_info| 
      start_time = WorkerStartTime.new(worker_info,@stale_worker_seconds)
      Job.new(worker: id,
             payload: worker_info["payload"],
          started_at: start_time.started_at,
            too_long: start_time.too_long?,
               queue: worker_info["queue"])
    }
  end

  def jobs_waiting
    Hash[@resque_data_store.queue_names.map { |queue_name|
      [
        queue_name,
        @resque_data_store.everything_in_queue(queue_name).map { |json|
          Resque.decode(json)
        }.map { |payload|
          Job.new(payload: payload, queue: queue_name)
        }
      ]
    }]
  end

private

  def workers_map(ids)
    Hash[@resque_data_store.workers_map(ids).map { |id,json| [id,(Resque.decode(json) rescue nil)] }]
  end

  class WorkerStartTime
    attr_reader :started_at

    def initialize(worker_info, stale_worker_seconds)
      @started_at = Time.parse(worker_info["run_at"]) rescue nil
      @too_long   = @started_at.nil? ? false : Time.now - @started_at >= stale_worker_seconds
    end

    def too_long?
      @too_long
    end
  end

end
