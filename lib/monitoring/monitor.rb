module Monitoring
  class Monitor
    def initialize(checker: checker,notifier: notifier)
      @checker  = checker
      @notifier = notifier
    end

    def monitor!
      @notifier.notify!(@checker.check!)
    end
  end
end
