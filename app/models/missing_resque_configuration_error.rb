class MissingResqueConfigurationError < StandardError
  def initialize(environment_variables,resque_name)
    super("Couldn't find environment variable for Resque #{resque_name}.  Tried: #{environment_variables.join(',')}")
  end
end
