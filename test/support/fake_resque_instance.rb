require 'support/explicit_interface_implementation'

class FakeResqueInstance
  extend ExplicitInterfaceImplementation
  implements ResqueInstance

  attr_reader :workers, :retried_jobs

  def initialize(attributes)
    @name         = attributes.fetch(:name)
    @jobs_running = attributes[:jobs_running] || []
    @jobs_waiting = attributes[:jobs_waiting] || []
    @jobs_failed  = attributes[:jobs_failed]  || []
    @workers      = attributes[:workers]      || []
    @retried_jobs = []
  end

  implement! def name
    @name
  end

  implement! def jobs_running
    @jobs_running
  end

  implement! def jobs_waiting
    @jobs_waiting
  end

  implement! def kill_worker(worker_id)
    @workers = @workers.reject { |worker| worker.id == worker_id }
  end

  implement! def jobs_failed(start=0,count=:all)
    count = @jobs_failed.size if count == :all
    @jobs_failed[start..(start + count - 1)]
  end

  implement! def retry_job(index_in_failed_queue)
    @retried_jobs << index_in_failed_queue
  end
end
