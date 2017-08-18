# frozen_string_literal: true

class FailedJob < Job
  attr_reader :id,
              :failed_at,
              :exception,
              :error,
              :backtrace,
              :worker,
              :retried_at

  def initialize(attributes = {})
    super(attributes)
    @id         = attributes[:id]
    @failed_at  = attributes[:failed_at]
    @exception  = attributes[:exception]
    @error      = attributes[:error]
    @backtrace  = attributes[:backtrace]
    @worker     = attributes[:worker]
    @retried_at = attributes[:retried_at]
  end
end
