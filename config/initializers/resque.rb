ResqueInstance.register_instance(name: "default", resque_data_store: Resque::DataStore.new(Redis.new))
