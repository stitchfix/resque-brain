module Monitoring
  class StaleWorkerCheck < Monitoring::Checker
    def check!
      Hash[@resques.all.map { |resque_instance|
        [resque_instance.name,resque_instance.jobs_running.select(&:too_long?)]
      }]
    end
  end
end
