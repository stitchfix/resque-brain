# frozen_string_literal: true

module Monitoring
  class Notifier
    # This will be given an array of CheckResult instances
    def notify!(_check_results)
      raise
    end
  end
end
