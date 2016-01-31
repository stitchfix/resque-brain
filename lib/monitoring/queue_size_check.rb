require 'ostruct'
module Monitoring
  class QueueSizeCheck < Monitoring::Checker
    def check!
      @resques.all.map { |resque_instance|
        resque_instance.jobs_waiting.keys.sort.map { |queue_name|
          jobs = resque_instance.jobs_waiting[queue_name]
          CheckResult.new(resque_name: resque_instance.name,
                          scope: queue_name,
                          check_name: "resque.queue_size",
                          check_count: jobs.size)
        }
      }.flatten
    end
  end
end
