require 'ostruct'
module Monitoring
  class QueueSizeCheck < Monitoring::Checker
    def check!
      @resques.all.map { |resque_instance|
        do_check(resque_instance)
      }.flatten
    end

  private

    def do_check(resque_instance)
      waiting_by_queue = resque_instance.waiting_by_queue
      waiting_by_queue.keys.sort.map { |queue_name|
        CheckResult.new(resque_name: resque_instance.name,
                        scope: queue_name,
                        check_name: "resque.queue_size",
                        check_count: waiting_by_queue[queue_name])
      }
    rescue => ex
      raise Monitoring::WrappedException.new(resque_instance.name,ex)
    end
  end
end
