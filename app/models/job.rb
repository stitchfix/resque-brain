class Job

  attr_reader :queue
  attr_reader :payload

  def initialize(attributes={})
    @queue      = attributes[:queue]
    @payload    = attributes[:payload]
  end

end
