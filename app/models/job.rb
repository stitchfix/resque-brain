class Job

  attr_reader :queue
  attr_reader :payload
  attr_reader :started_at
  attr_reader :worker
  attr_reader :too_long

  def initialize(attributes={})
    @queue = attributes[:queue]
    @payload = attributes[:payload]
    @started_at = attributes[:started_at]
    @worker = attributes[:worker]
    @too_long = attributes[:too_long]
  end

end
