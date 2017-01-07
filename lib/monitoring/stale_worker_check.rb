require_relative "wrapped_exception"
require_relative 'checker'

module Monitoring
  class StaleWorkerCheck < Monitoring::Checker

  private

    def do_check(resque_instance)
      CheckResult.new(resque_name: resque_instance.name,
                      check_name: "resque.stale_workers",
                      check_count: resque_instance.jobs_running.select(&:too_long?).size)
    end
  end
end
