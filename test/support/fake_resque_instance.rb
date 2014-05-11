class FakeResqueInstance
  attr_reader :jobs_running
  attr_reader :jobs_waiting

  attr_reader :name
  def initialize(attributes)
    @name         = attributes.fetch(:name)
    @jobs_running = attributes[:jobs_running] || []
    @jobs_waiting = attributes[:jobs_waiting] || []
    @jobs_failed  = attributes[:jobs_failed]  || []
  end

  def jobs_failed(start=0,count=:all)
    count = @jobs_failed.size if count == :all
    @jobs_failed[start..(start + count - 1)]
  end
end
