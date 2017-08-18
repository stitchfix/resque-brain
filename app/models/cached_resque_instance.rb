require "active_support/core_ext/module/delegation"

class CachedResqueInstance
  def initialize(resque_instance)
    @resque_instance = resque_instance
    @cache_key_base = "ResqueInstance:#{@resque_instance.name}:"
  end

  delegate :name,
           :kill_worker,
           :resque_data_store,

           to: :@resque_instance

  def failed
    fetch_from_cache(:failed) do
      @resque_instance.failed
    end
  end

  def running
    fetch_from_cache(:running) do
      @resque_instance.running
    end
  end

  def running_too_long
    fetch_from_cache(:running_too_long) do
      @resque_instance.running_too_long
    end
  end

  def waiting
    fetch_from_cache(:waiting) do
      @resque_instance.waiting
    end
  end

  def waiting_by_queue
    fetch_from_cache(:waiting_by_queue) do
      @resque_instance.waiting_by_queue
    end
  end

  def jobs_running
    fetch_from_cache(:jobs_running) do
      @resque_instance.jobs_running
    end
  end

  def jobs_waiting
    fetch_from_cache(:jobs_waiting) do
      @resque_instance.jobs_waiting
    end
  end

  def jobs_failed(start=0,count=:all)
    if (start == 0) && (count == :all)
      fetch_from_cache(:jobs_failed) do
        @resque_instance.jobs_failed
      end
    else
      @resque_instance.jobs_failed(start,count)
    end
  end

  def schedule
    fetch_from_cache(:schedule, expires_in: 1.hour) do
      @resque_instance.schedule
    end
  end


  [
    :retry_job,
    :clear_job,
    :retry_all,
    :clear_all,
  ].each do |method_that_should_clear_failed_jobs_cache|
    define_method method_that_should_clear_failed_jobs_cache do |*args|
      clear_cache_for(:failed)
      clear_cache_for(:jobs_failed)
      @resque_instance.send(method_that_should_clear_failed_jobs_cache,*args)
    end
  end

  def queue_job_from_schedule(schedule_element)
    clear_cache_for(:jobs_waiting)
    clear_cache_for(:jobs_running)
    clear_cache_for(:waiting_by_queue)
    @resque_instance.send(:queue_job_from_schedule,schedule_element)
  end

private

  def fetch_from_cache(method,options={},&block)
    options = { race_condition_ttl: 5, expires_in: 5.minutes }.merge(options)

    Rails.cache.fetch(cache_key(method),options) do
      block.()
    end
  end

  def clear_cache_for(method)
    Rails.cache.delete(cache_key(method))
  end

  def cache_key(method)
    "#{@cache_key_base}#{method}"
  end

end
