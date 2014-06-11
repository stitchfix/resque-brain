if Rails.env.test?
  RESQUES = Resques.new([
    ResqueInstance.new(
      name: "localhost", 
      resque_data_store: Resque::DataStore.new(Redis::Namespace.new(:resque,redis: Redis.new)),
      stale_worker_seconds: (ENV['RESQUE_BRAIN_STALE_WORKER_SECONDS'] || '3600').to_i
    )
  ])
else
  RESQUES = Resques.from_environment
end
