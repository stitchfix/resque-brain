require 'resque/data_store'

class FakeResqueDataStore
  def self.implement!(method_name)
    unless Resque::DataStore.instance_methods.include?(method_name)
      raise "Resque::DataStore does not implement #{method_name}"
    end
  end
  QUEUES = {
    foo: [
      { class: "Foo", args: [] },
      { class: "Foo", args: [] },
      { class: "Foo", args: [] },
      { class: "Foo", args: [] },
      { class: "Foo", args: [] },
    ],
    bar: [
      { class: "Bar", args: [] },
      { class: "Bar", args: [] },
    ],
  }

  WORKERS = {
          mail: nil,
         cache: { "queue" => :cache,      "payload" => "whatever", "run_at" => Time.now - (3600) },
     generator: { "queue" => :generator,  "payload" => "yupyup",   "run_at" => Time.now - (60) },
    purchasing: { "queue" => :purchasing, "payload" => "blah",     "run_at" => Time.now },
  }

  implement! def queue_names
    QUEUES.keys
  end

  implement! def queue_size(queue_name)
    QUEUES[queue_name].size
  end

  implement! def num_failed
    10
  end

  implement! def worker_ids
    WORKERS.keys
  end

  implement! def workers_map(worker_ids)
    WORKERS.select {|k,v| worker_ids.include?(k) }
  end
end
