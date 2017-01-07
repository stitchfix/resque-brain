require 'monitoring/monitor'
require 'monitoring/librato_notifier'
require 'monitoring/failed_job_by_class_check'
require 'monitoring/failed_job_check'
require 'monitoring/queue_size_check'
require 'monitoring/stale_worker_check'

class MonitorJob

  def self.perform(checker_name)
    monitor = Monitoring::Monitor.new(
       checker: checker(checker_name),
       notifier: notifier(checker_name))

    monitor.monitor!
  end

  def self.notifier(name)
    {
     failed: Monitoring::LibratoNotifier.new(unit: "jobs"),
     failed_by_class: Monitoring::LibratoNotifier.new(unit: "jobs"),
     stale_workers: Monitoring::LibratoNotifier.new(type: :measure, unit: "workers"),
     queue_sizes: Monitoring::LibratoNotifier.new(unit: "jobs")
    }[name.to_sym]
  end

  def self.checker(name)
    {
     failed: Monitoring::FailedJobCheck.new,
     failed_by_class: Monitoring::FailedJobByClassCheck.new,
     stale_workers: Monitoring::StaleWorkerCheck.new,
     queue_sizes: Monitoring::QueueSizeCheck.new
    }[name.to_sym]
  end
end
