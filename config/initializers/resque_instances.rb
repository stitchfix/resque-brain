if Rails.env.test?
  RESQUES = Resques.new([
    ResqueInstance.new(
      name: "localhost", 
      resque_data_store: Resque::DataStore.new(Redis::Namespace.new(:resque,redis: Redis.new))
    )
  ])
else
  RESQUES = Resques.from_environment
end
