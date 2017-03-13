require 'monitoring/monitor'
require 'monitoring/librato_notifier'
require 'monitoring/aws_notifier'
require 'monitoring/failed_job_by_class_check'
require 'monitoring/failed_job_check'
require 'monitoring/queue_size_check'
require 'monitoring/stale_worker_check'
require "active_support/core_ext/string/inflections.rb"

class MonitorJob

  def self.perform(checker_klass_name,
                   notifier_klass_name = "Monitoring::LibratoNotifier",
                   notifier_args = { "unit" => "jobs" }
                  )
    checker_klass = checker_klass_name.constantize
    checker = checker_klass.new
    notifier_args = notifier_args.map { |k,v| [k.to_sym,v] }.to_h
    notifier = notifier_klass_name.constantize.new(notifier_args)
    begin
      Monitoring::Monitor.new(checker: checker, notifier: notifier).monitor!
    rescue => ex
      Rails.logger.info("Ignoring #{ex.class} from MonitorJob: #{ex.message}")
    end
  end
end
