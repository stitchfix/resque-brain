require 'ostruct'
module Monitoring
  class QueueSizeCheck < Monitoring::Checker
    def check!
      Hash[@resques.all.map { |resque_instance|
        [resque_instance.name,resque_instance.jobs_waiting]
      }]
    end
  end
end
