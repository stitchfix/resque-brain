# frozen_string_literal: true

require 'support/explicit_interface_implementation'

class FakeResqueInstance
  extend ExplicitInterfaceImplementation
  implements ResqueInstance

  attr_reader :workers,
              :retried_jobs,
              :cleared_jobs,
              :retried_all,
              :cleared_all,
              :schedule,
              :queued_scheduled_jobs

  def initialize(attributes)
    @name         = attributes.fetch(:name)
    @jobs_running = attributes[:jobs_running] || {}
    @jobs_waiting = attributes[:jobs_waiting] || []
    @jobs_failed  = attributes[:jobs_failed]  || []
    @workers      = attributes[:workers]      || []
    @schedule     = attributes[:schedule]     || []
    @retried_jobs = []
    @cleared_jobs = []
    @queued_scheduled_jobs = []
  end

  implement! def waiting_by_queue
    @jobs_waiting.map { |queue, jobs| [queue, jobs.size] }.to_h
  end

  implement! attr_reader :name

  implement! attr_reader :jobs_running

  implement! attr_reader :jobs_waiting

  implement! def kill_worker(worker_id)
    @workers = @workers.reject { |worker| worker.id == worker_id }
  end

  implement! def jobs_failed(start = 0, count = :all)
    count = @jobs_failed.size if count == :all
    @jobs_failed[start..(start + count - 1)]
  end

  implement! def retry_job(index_in_failed_queue)
    @retried_jobs << index_in_failed_queue
  end

  implement! def clear_job(index_in_failed_queue)
    @cleared_jobs << index_in_failed_queue
  end

  implement! def retry_all
    @retried_all = true
  end

  implement! def clear_all
    @cleared_all = true
  end

  implement! def queue_job_from_schedule(schedule_element)
    @queued_scheduled_jobs << schedule_element
  end
end
