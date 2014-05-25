module Monitoring
  class Monitor
    def initialize(checker,notifier)
      @checker  = checker
      @notifier = notifier
    end

    def monitor!
      @notifier.notify!(@checker.check!)
    end
  end
end
