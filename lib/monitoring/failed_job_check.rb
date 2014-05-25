require 'ostruct'
module Monitoring
  class FailedJobCheck < Monitoring::Checker
    def check!
      Hash[@resques.all.map { |resque_instance|
        [resque_instance.name,resque_instance.jobs_failed]
      }]
    end
  end
end
