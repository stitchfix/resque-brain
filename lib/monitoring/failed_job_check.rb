require 'ostruct'
module Monitoring
  class FailedJobCheck < Monitoring::Checker
    def check!
      @resques.all.map { |resque_instance|
        do_check(resque_instance)
      }
    end

  private

    def do_check(resque_instance)
        CheckResult.new(resque_name: resque_instance.name,
                        check_name: "resque.failed_jobs",
                        check_count: resque_instance.failed)
    rescue => ex
      raise Monitoring::WrappedException.new(resque_instance.name,ex)
    end
  end
end
