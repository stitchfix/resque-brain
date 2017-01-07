require 'monitoring/monitor'
require 'monitoring/librato_notifier'
require 'monitoring/failed_job_by_class_check'
require 'monitoring/failed_job_check'
require 'monitoring/queue_size_check'
require 'monitoring/stale_worker_check'

class MonitorJob

  def self.perform(checker_name, error_handling = :raise)
    checker,notifier = CHECKS_AND_NOTIFIERS.fetch(checker_name.to_sym).()
    begin
      Monitoring::Monitor.new(checker: checker, notifier: notifier).monitor!
    rescue => ex
      if error_handling.to_sym == :ignore_and_log_errors
        Rails.logger.info("Ignoring #{ex.class} from MonitorJob: #{ex.message}")
      else
        raise ex
      end
    end
  end

  CHECKS_AND_NOTIFIERS = {
    failed: ->() {
      [ Monitoring::FailedJobCheck.new,        Monitoring::LibratoNotifier.new(unit: "jobs") ]
    },
    failed_by_class: ->() {
      [ Monitoring::FailedJobByClassCheck.new, Monitoring::LibratoNotifier.new(unit: "jobs") ]
    },
    stale_workers: ->() {
      [ Monitoring::StaleWorkerCheck.new,      Monitoring::LibratoNotifier.new(unit: "workers", type: :measure) ]
    },
    queue_sizes: ->() {
      [ Monitoring::QueueSizeCheck.new,        Monitoring::LibratoNotifier.new(unit: "jobs") ]
    },
  }
end
