module ResqueHelpers
  def resque_instance(name,namespace)
    redis = Redis::Namespace.new(namespace,redis: Redis.new)
    resque_data_store = Resque::DataStore.new(redis)
    ResqueInstance.new(name: name, resque_data_store: resque_data_store)
  end

  def add_failed_jobs(num_failed: nil, resque_instance: nil, job_class_names: nil)
    raise 'you must supply num_failed or job_class_names' if num_failed.nil? && job_class_names.nil?
    job_class_names ||= num_failed.times.map { "Baz" }

    job_class_names.each_with_index do |class_name,i|
      resque_instance.resque_data_store.push_to_failed_queue(Resque.encode(
        failed_at: Time.now.utc.iso8601,
        payload: { class: class_name, args: [ i ]},
        exception: "Resque::TermException",
        error: "SIGTERM",
        backtrace: [ "foo","bar","blah"],
        queue: "mail",
        worker: "worker#{i}",
      ))
    end
    resque_instance
  end

  def add_jobs(jobs: {}, resque_instance: nil)
    jobs.each do |queue,num_jobs|
      num_jobs.times do
        resque_instance.resque_data_store.push_to_queue(queue,Resque.encode(class: "Blah", args: [1,2,3]))
      end
    end

    resque_instance
  end

  def add_workers(num_stale: 0, total_workers: 2, resque_instance: nil)
    total_workers = [num_stale,total_workers].max

    (0..(num_stale-1)).each do |i|
      worker = Resque::Worker.new("#{resque_instance.name}_mail#{i}")
      resque_instance.resque_data_store.register_worker(worker)
      resque_instance.resque_data_store.set_worker_payload(
        worker,
        Resque.encode(
          :queue   => "#{resque_instance.name}_mail#{i}",
          :run_at  => (Time.now - 2.hours).utc.iso8601,
          :payload => { class: "RunningTypeJob", args: [4,5,6] }
        )
      )
    end
    (num_stale..(total_workers-1)).each do |i|
      worker = Resque::Worker.new("#{resque_instance.name}_cache#{i}")
      resque_instance.resque_data_store.register_worker(worker)
      resque_instance.resque_data_store.set_worker_payload(
        worker,
        Resque.encode(
          :queue   => "#{resque_instance.name}_cache#{i}",
          :run_at  => Time.now.utc.iso8601,
          :payload => { class: "RunningTypeJob", args: [4,5,6] }
        )
      )
    end
    resque_instance
  end
end
