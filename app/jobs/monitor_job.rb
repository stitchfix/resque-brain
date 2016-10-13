class MonitorJob

  def self.perform(checker_name)
    monitor = Monitoring::Monitor.new(
       checker: checker(checker_name),
       notifier: Monitoring::LibratoNotifier.new(unit: "jobs"))
    
    monitor.monitor!
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
