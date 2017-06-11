require "active_support/core_ext/module/delegation"

class CachedResqueInstance
  def initialize(resque_instance)
    @resque_instance = resque_instance
    @cache_key_base = "ResqueInstance:#{@resque_instance.name}:"
  end

  delegate :name,
           :retry_job,
           :clear_job,
           :retry_all,
           :clear_all,
           :kill_worker,
           :queue_job_from_schedule,
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

private

  def fetch_from_cache(method,options={},&block)
    options = { race_condition_ttl: 5, expires_in: 5.minutes }.merge(options)
    cache_key = "#{@cache_key_base}#{method}"

    Rails.cache.fetch(cache_key,options) do
      block.()
    end
  end

end
