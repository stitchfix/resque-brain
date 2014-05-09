class FakeResqueInstance
  attr_reader :jobs_running
  attr_reader :jobs_waiting
  attr_reader :jobs_failed

  attr_reader :name
  def initialize(attributes)
    @name         = attributes.fetch(:name)
    @jobs_running = attributes[:jobs_running] || []
    @jobs_waiting = attributes[:jobs_waiting] || []
    @jobs_failed  = attributes[:jobs_failed]  || []
  end
end
