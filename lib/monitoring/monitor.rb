module Monitoring
  class Monitor
    def initialize(checker: nil,notifier: nil)
      raise "both checker and notifier are required" if checker.nil? || notifier.nil?
      @checker  = checker
      @notifier = notifier
    end

    def monitor!
      @notifier.notify!(@checker.check!)
    end
  end
end
