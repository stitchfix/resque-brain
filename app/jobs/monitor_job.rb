class MonitorJob

  def self.perform(checker)
    Rake::Task["monitor:#{checker}"].invoke
  end

end
