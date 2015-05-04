class ResqueUrl
  def initialize(resque_name)
    @resque_name = resque_name
  end

  def url
    @url ||= environment_variables.map { |environment_variable|
      ENV[environment_variable]
    }.compact.first
    if @url.nil?
      raise MissingResqueConfigurationError.new(environment_variables,@resque_name)
    end
    @url
  end

  private

  def environment_variables
    [
      "RESQUE_BRAIN_INSTANCES_#{@resque_name}", 
      "#{@resque_name.gsub(/-/,'_').upcase}_RESQUE_REDIS_URL",
    ]
  end
end
