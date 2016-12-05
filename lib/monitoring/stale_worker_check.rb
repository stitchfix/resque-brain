require_relative "wrapped_exception"

module Monitoring
  class StaleWorkerCheck < Monitoring::Checker

    def check!
      @resques.all.map { |resque_instance|
        do_check(resque_instance)
      }
    end

  private

    def do_check(resque_instance)
      CheckResult.new(resque_name: resque_instance.name,
                      check_name: "resque.stale_workers",
                      check_count: resque_instance.jobs_running.select(&:too_long?).size)
    rescue => ex
      raise Monitoring::WrappedException.new(resque_instance.name,ex)
    end
  end
end
