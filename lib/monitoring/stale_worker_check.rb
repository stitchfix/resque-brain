module Monitoring
  class StaleWorkerCheck < Monitoring::Checker
    def check!
      @resques.all.map { |resque_instance|
        CheckResult.new(resque_name: resque_instance.name,
                        check_name: "resque.stale_workers",
                        check_count: resque_instance.jobs_running.select(&:too_long?).size)
      }
    end
  end
end
