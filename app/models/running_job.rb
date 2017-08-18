# frozen_string_literal: true

class RunningJob < Job
  attr_reader :started_at
  attr_reader :worker
  attr_reader :too_long

  def initialize(attributes = {})
    super(attributes)
    @started_at = attributes[:started_at]
    @worker     = attributes[:worker]
    @too_long   = attributes[:too_long]
  end

  def too_long?
    @too_long
  end
end
