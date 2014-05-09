class FailedJob < Job

  attr_reader :failed_at
  attr_reader :exception
  attr_reader :error
  attr_reader :backtrace
  attr_reader :worker

  def initialize(attributes={})
    super(attributes)
    @failed_at  = attributes[:failed_at]
    @exception  = attributes[:exception]
    @error      = attributes[:error]
    @backtrace  = attributes[:backtrace]
    @worker     = attributes[:worker]
  end
end
