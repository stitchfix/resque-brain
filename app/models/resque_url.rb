class ResqueUrl

  def self.recognize(env_var_name)
    upper_name = if env_var_name =~ /RESQUE_BRAIN_INSTANCES_(.*)$/
                   $1
                 elsif env_var_name =~ /(^.*)_RESQUE_REDIS_URL$/
                   $1
                 elsif env_var_name =~ /(^.*)_REDIS_URL$/
                   $1
                 else
                   nil
                 end
    if upper_name
      self.new(upper_name.gsub(/_/,'-').downcase)
    else
      nil
    end
  end

  attr_reader :resque_name

  def initialize(resque_name)
    @resque_name = resque_name
  end

  def namespace_env_var
    @resque_name.upcase.gsub(/-/,'_') + "_NAMESPACE"
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
      "RESQUE_BRAIN_INSTANCES_#{@resque_name.gsub(/-/,'_')}",
      "#{@resque_name.gsub(/-/,'_').upcase}_RESQUE_REDIS_URL",
      "#{@resque_name.gsub(/-/,'_').upcase}_REDIS_URL",
    ]
  end
end
