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

  FAILED = [
    {
      "failed_at" => (Time.now.utc - 3600).iso8601,
      "payload" => {
        "class" => "SomeFailingJob",
        "args" => [500145, 1114130]
      },
      "exception" => "Resque::TermException",
      "error" => "SIGTERM",
      "backtrace" => [
        "/app/app/services/blah_whatever.rb:57:in `block in whatever!'",
        "/app/app/services/blah_whatever.rb:77:in `call'",
        "/app/app/services/blah_whatever.rb:77:in `with_whatever'",
        "/app/app/services/blah_whatever.rb:52:in `whatever!'",
        "/app/app/services/blah_whatever.rb:11:in `whatever_items_from_bleorgh'",
        "/app/lib/exceptions/exception_augmenter.rb:10:in `call'",
        "/app/lib/exceptions/exception_augmenter.rb:10:in `augment_all_exceptions_with'",
        "/app/app/jobs/concerns/whatevering_job.rb:6:in `augment_exceptions_with_remediation_help'",
        "/app/app/jobs/whatever_inconsistent_blagh_job.rb:8:in `perform'"
      ],
      "worker" => "some_worker_id",
      "queue" => "mail"
    },
    {
      "failed_at" => Time.now.utc.iso8601,
      "payload" => {
        "class" => "SomeOtherFailingJob",
        "args" => ["blah"]
      },
      "exception" => "KeyError",
      "error" => "No Such key 'foobar'",
      "backtrace" => [
        "/app/app/services/blah_whatever.rb:57:in `block in whatever!'",
        "/app/app/services/blah_whatever.rb:77:in `call'",
        "/app/app/services/blah_whatever.rb:77:in `with_whatever'",
        "/app/app/jobs/concerns/whatevering_job.rb:6:in `augment_exceptions_with_remediation_help'",
        "/app/app/jobs/whatever_inconsistent_blagh_job.rb:8:in `perform'"
      ],
      "worker" => "some_other_worker_id",
      "queue" => "cache"
    },
    {
      "failed_at" => "mangled time",
      "payload" => "mangled payload"
    }
  ]

  implement! def queue_names
    QUEUES.keys
  end

  implement! def queue_size(queue_name)
    QUEUES[queue_name].size
  end

  implement! def num_failed
    FAILED.size
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

  implement!  def list_range(key, start = 0, count = 1)
    raise 'only failed is allowed' unless key == :failed
    FAILED[start..(count-1)].map { |_| Resque.encode(_) }
  end
end
