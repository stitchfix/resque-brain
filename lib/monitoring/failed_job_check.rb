require 'ostruct'
module Monitoring
  class FailedJobCheck < Monitoring::Checker
    def check!
      @resques.all.map { |resque_instance|
        CheckResult.new(resque_name: resque_instance.name,
                        check_name: "resque.failed_jobs",
                        check_count: resque_instance.failed)
      }
    end
  end
end
