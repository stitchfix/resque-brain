# frozen_string_literal: true

class ResqueUrl
  def self.recognize(env_var_name)
    upper_name = if env_var_name =~ /RESQUE_BRAIN_INSTANCES_(.*)$/
                   Regexp.last_match(1)
                 elsif env_var_name =~ /(^.*)_RESQUE_REDIS_URL$/
                   Regexp.last_match(1)
                 elsif env_var_name =~ /(^.*)_REDIS_URL$/
                   Regexp.last_match(1)
                 end
    new(upper_name.tr('_', '-').downcase) if upper_name
  end

  attr_reader :resque_name

  def initialize(resque_name)
    @resque_name = resque_name
  end

  def namespace_env_var
    @resque_name.upcase.tr('-', '_') + '_NAMESPACE'
  end

  def url
    @url ||= environment_variables.map do |environment_variable|
      ENV[environment_variable]
    end.compact.first
    if @url.nil?
      raise MissingResqueConfigurationError.new(environment_variables, @resque_name)
    end
    @url
  end

  private

  def environment_variables
    [
      "RESQUE_BRAIN_INSTANCES_#{@resque_name}",
      "RESQUE_BRAIN_INSTANCES_#{@resque_name.tr('-', '_')}",
      "#{@resque_name.tr('-', '_').upcase}_RESQUE_REDIS_URL",
      "#{@resque_name.tr('-', '_').upcase}_REDIS_URL"
    ]
  end
end
