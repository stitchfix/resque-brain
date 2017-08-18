# frozen_string_literal: true

module Monitoring
  class Monitor
    def initialize(checker: nil, notifier: nil)
      raise ArgumentError, 'both checker and notifier are required' if checker.nil? || notifier.nil?
      @checker  = checker
      @notifier = notifier
    end

    def monitor!
      @notifier.notify!(@checker.check!)
    end
  end
end
