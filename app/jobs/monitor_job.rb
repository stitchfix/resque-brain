class MonitorJob

  def self.perform(checker)
    monitor = Monitoring::Monitor.new(
       checker: checker(name),
      notifier: Monitoring::LibratoNotifier.new(unit: "jobs"))
    monitor.monitor!
  end

  def self.checker(name)
    {
     failed: Monitoring::FailedJobCheck.new,
     failed_by_class: Monitoring::FailedJobByClassCheck.new,
     stale_workers: Monitoring::StaleWorkerCheck.new,
     queue_sizes: Monitoring::QueueSizeCheck
    }[name.to_sym]
  end
end
