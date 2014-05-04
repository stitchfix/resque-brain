class ResqueInstance
  def self.all
    @instances.values
  end

  def self.register_instance(opts)
    @instances ||= {}
    @instances[opts[:name]] = self.new(opts)
  end

  def self.unregister_all!
    @instances = {}
  end

  def self.find(name)
    @instances[name]
  end

  attr_reader :name,
              :resque_data_store

  def initialize(config={})
    @name              = config[:name]
    @resque_data_store = config[:resque_data_store]
  end
end
