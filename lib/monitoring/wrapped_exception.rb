# frozen_string_literal: true

module Monitoring
  class WrappedException < StandardError
    def initialize(message, ex)
      super("#{message}: #{ex.message}")
      @wrapped_exception = ex
    end

    def backtrace
      @wrapped_exception.backtrace
    end
  end
end
