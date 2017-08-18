# frozen_string_literal: true

class ResqueInstance
  attr_reader :name,
              :resque_data_store

  # Create an access-point to a Resque instance.
  # config:: options and configuration:
  #          :name:: logical name of this resque.  Please avoid spaces
  #          :resque_data_store:: a Resque::DataStore instance to use to acccess resque's internals
  #          :stale_worker_seconds:: number of seconds a worker can be running before being considered stale.  Default 3600
  def initialize(config = {})
    @name                 = config[:name]
    @resque_data_store    = config[:resque_data_store]
    @stale_worker_seconds = config[:stale_worker_seconds] || 3600
  end

  # Return the number of failed jobs
  def failed
    @resque_data_store.num_failed
  end

  # Return the number of running jobs
  def running
    worker_ids = Array(@resque_data_store.worker_ids)
    return 0 if worker_ids.empty?
    workers_map(worker_ids).reject { |_, worker_info| worker_info.nil? }.size
  end

  # Return the number of running jobs that are running "too long" based on the `:stale_worker_seconds` configuration value
  def running_too_long
    worker_ids = Array(@resque_data_store.worker_ids)
    return 0 if worker_ids.empty?
    workers_map(worker_ids).reject do |_, worker_info|
      worker_info.nil?
    end.select do |_, worker_info|
      WorkerStartTime.new(worker_info, @stale_worker_seconds).too_long?
    end.size
  end

  # Return the number of jobs waiting, in all queues
  def waiting
    @resque_data_store.queue_names.reduce(0) do |current_sum, queue_name|
      current_sum + @resque_data_store.queue_size(queue_name)
    end
  end

  # Return the number of jobs waiting, by queue.  Hash of queue_name => number of jobs waiting
  def waiting_by_queue
    Hash[@resque_data_store.queue_names.map do |queue_name|
      [queue_name, @resque_data_store.queue_size(queue_name)]
    end]
  end

  # Return all jobs that are currently running as an array of `RunningJob` instances
  def jobs_running
    worker_ids = Array(@resque_data_store.worker_ids)
    return [] if worker_ids.empty?
    workers_map(worker_ids).reject { |_, worker_info| worker_info.nil? }.map do |resque_key, worker_info|
      start_time = WorkerStartTime.new(worker_info, @stale_worker_seconds)
      worker_id = resque_key.gsub(/^worker:/, '')
      RunningJob.new(worker: worker_id,
                     payload: worker_info['payload'],
                     started_at: start_time.started_at,
                     too_long: start_time.too_long?,
                     queue: worker_info['queue'])
    end
  end

  # Return a hash of all jobs waiting, where the key is the name of the queue and the value
  # being an array of `Job` instances.
  def jobs_waiting
    Hash[@resque_data_store.queue_names.map do |queue_name|
      [
        queue_name,
        @resque_data_store.everything_in_queue(queue_name).map do |json|
          Resque.decode(json)
        end.map do |payload|
          Job.new(payload: payload, queue: queue_name)
        end
      ]
    end]
  end

  # Return failed jobs either all or over a rage, as an Array of `FailedJob`.
  # The failed queue is only accessible via indeces, but it does fill up
  # FIFO, so the indeces are stable as long as no job is removed.
  #
  # start:: where to start, 0 is the default and is the first element
  # count:: number of jobs to return, or `:all` for all jobs
  def jobs_failed(start = 0, count = :all)
    count = @resque_data_store.num_failed if count == :all
    failed_payloads = @resque_data_store.list_range(:failed, start, count)
    failed_payloads = [failed_payloads] unless failed_payloads.is_a?(Array)
    return [] if failed_payloads.nil?
    failed_payloads.map do |json|
      Resque.decode(json)
    end.each_with_index.map do |failed_job, index|
      FailedJob.new(
        id: index + start,
        queue: failed_job['queue'],
        payload: failed_job['payload'],
        exception: failed_job['exception'],
        error: failed_job['error'],
        backtrace: failed_job['backtrace'],
        worker: failed_job['worker'],
        failed_at: (begin
                      Time.parse(failed_job['failed_at'])
                    rescue
                      nil
                    end),
        retried_at: (begin
                       Time.parse(failed_job['retried_at'])
                     rescue
                       nil
                     end)
      )
    end
  end

  # Retry a job at index `index_in_failed_queue` of the failed queue.
  def retry_job(index_in_failed_queue)
    item = Resque.decode(@resque_data_store.list_range(:failed, index_in_failed_queue))
    item['retried_at'] = Time.now.strftime('%Y/%m/%d %H:%M:%S')
    @resque_data_store.update_item_in_failed_queue(index_in_failed_queue, Resque.encode(item))
    @resque_data_store.push_to_queue(item['queue'], Resque.encode(item['payload']))
  end

  # Remove a job from the failed queue.
  #
  # Note that after this completes, any index you have stored to the failed queue is likely going to point to a
  # different failed job.  You should refresh any view of the failed queue you have.
  def clear_job(index_in_failed_queue)
    @resque_data_store.remove_from_failed_queue(index_in_failed_queue)
  end

  # Retry all failed jobs
  def retry_all
    @resque_data_store.num_failed.times do |index|
      retry_job(index)
    end
  end

  # Clear all failed jobs
  def clear_all
    @resque_data_store.clear_failed_queue
  end

  def kill_worker(_worker_id)
    raise
  end

  # Get the schedule, if present, as an array of ScheduleElement instances
  #
  # This relies on the internals of resque-scheduler's implementation.  Because it
  # must depend on the single, global Resque instances, we can't use that, so we have to reach
  # into the underlying redis.  Ugh.
  def schedule
    resque_schedule = @resque_data_store.hgetall('schedules')
    return [] if resque_schedule.nil? || !resque_schedule.is_a?(Hash)
    resque_schedule.map do |name, schedule|
      schedule = JSON.parse(schedule)
      ScheduleElement.new(name: name,
                          args: schedule['args'],
                          cron: schedule['cron'],
                          klass: schedule['class'],
                          queue: schedule['queue'],
                          description: schedule['description'],
                          every: schedule['every'])
    end
  end

  def queue_job_from_schedule(schedule_element)
    @resque_data_store.push_to_queue(schedule_element.queue, Resque.encode(class: schedule_element.klass, args: schedule_element.args))
  end

  private

  def workers_map(ids)
    Hash[@resque_data_store.workers_map(ids).map do |id, json|
      [id, (begin
                                                               Resque.decode(json)
                                                             rescue
                                                               nil
                                                             end)]
    end]
  end

  class WorkerStartTime
    attr_reader :started_at

    def initialize(worker_info, stale_worker_seconds)
      @started_at = begin
                      Time.parse(worker_info['run_at'])
                    rescue
                      nil
                    end
      @too_long   = @started_at.nil? ? false : Time.now - @started_at >= stale_worker_seconds
    end

    def too_long?
      @too_long
    end
  end
end
