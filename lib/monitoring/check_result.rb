module Monitoring
  class CheckResult
    attr_reader :resque_name, # Name of the resque the check checked
                :scope,       # Refined scope inside this resque, if relevenat (e.g. queue name or class name)
                :check_name,  # Name of the thing checked
                :check_count  # Count related to what was being checked

    def initialize(resque_name: nil,check_name: nil,check_count: nil, scope: nil)
      @resque_name = required! resque_name, "resque_name"
      @check_name  = required! check_name, "check_name"
      @check_count = required! check_count, "check_count", :to_i
      @scope       = optional scope
    end

  private

    def required!(value, name, conversion = :to_s)
      raise ArgumentError, "#{name} is required" if value.nil?
      value.send(conversion)
    end

    def optional(value)
      if value.nil?
        nil
      else
        value.to_s
      end
    end
  end
end
