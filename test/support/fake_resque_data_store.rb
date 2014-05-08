require 'rubygems'
require 'resque'
require 'resque/data_store'

class FakeResqueDataStore
  def self.implement!(method_name)
    unless Resque::DataStore.instance_methods.include?(method_name)
      raise "Resque::DataStore does not implement #{method_name}"
    end
  end
  QUEUES = {
    "foo" => [
      { "class" => "FooJob", "args" => [1] },
      { "class" => "FooJob", "args" => [2] },
      { "class" => "FooJob", "args" => [3] },
      { "class" => "FooJob", "args" => [4] },
      { "class" => "FooJob", "args" => [5] },
    ],
    "bar" => [
      { "class" => "BarJob", "args" => [1] },
      { "class" => "BarJob", "args" => [2] },
    ],
  }

  WORKERS = {
          mail: nil,
         cache: { "queue" => "cache",      "payload" => { "class" => "CacheJob",      "args" => ["whatever"] }, "run_at" => (Time.now - (3600)).iso8601 },
     generator: { "queue" => "generator",  "payload" => { "class" => "GeneratorJob",  "args" => [ "yupyup"] },  "run_at" => (Time.now - (60)).iso8601 },
    purchasing: { "queue" => "purchasing", "payload" => { "class" => "PurchasingJob", "args" => [ "blah"] },    "run_at" => Time.now.iso8601 },
      indexing: { "queue" => "indexing",   "payload" => { "class" => "IndexingJob",   "args" => [ "blah"] },    "run_at" => "mangled timestamp" },
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
    Hash[WORKERS.select {|k,v| worker_ids.include?(k) }.map { |k,v|
      [k,Resque.encode(v)]
    }]
  end

  implement! def everything_in_queue(queue)
    QUEUES[queue].map { |_| Resque.encode(_) }
  end
end
