# frozen_string_literal: true

namespace :jobs do
  task clear: :environment do
    raise 'This is for development only' unless Rails.env.development?
    RESQUES.all.each do |resque_instance|
      redis = resque_instance.resque_data_store.redis
      puts "Clear all data from #{resque_instance.name} (#{redis.client.host}:#{redis.client.port}/#{redis.client.db})? ('yes' to continue)"
      if $stdin.gets =~ /yes/i
        resque_instance.resque_data_store.redis.flushall
      else
        exit 1
      end
    end
  end

  task seed: :environment do
    raise 'This is for development only' unless Rails.env.development?
    class_names = [
      %w[RefreshCacheJob cache],
      %w[WelcomeMailerJob mail],
      %w[SyncShippingInfoJob shipping],
      %w[DeployJob deploys]
    ]
    exceptions = [
      ['Resque::TermException', 'SIGTERM'],
      ['Errno::ENOINT', 'SIGTERM'],
      ['ActiveRecord::NotFoundError', 'No Person with Id 5']
    ]
    empty_queues = %w[
      checkout
      pdf
      accounting
    ]

    def make_backtrace
      raise 'wtf'
    rescue => ex
      ex.backtrace
    end
    RESQUES.all.each_with_index do |resque_instance, i|
      # make failed
      ((i + 1) * 2).times do
        class_name, queue_name = class_names.sample
        exception, message = exceptions.sample
        resque_instance.resque_data_store.push_to_failed_queue(Resque.encode(
                                                                 failed_at: (Time.now.utc - (i * 1000 * 60)).iso8601,
                                                                 payload: { class: class_name, args: [i] },
                                                                 exception: exception,
                                                                 error: message,
                                                                 backtrace: make_backtrace,
                                                                 queue: queue_name,
                                                                 worker: "worker#{i}"
        ))
      end

      # make running
      (i + 1).times do
        class_name, queue_name = class_names.sample
        worker = Resque::Worker.new(queue_name)
        resque_instance.resque_data_store.register_worker(worker)
        resque_instance.resque_data_store.set_worker_payload(
          worker,
          Resque.encode(
            queue: queue_name,
            run_at: Time.now.utc.iso8601,
            payload: { class: class_name, args: [4, 5, 6] }
          )
        )
      end

      # make running too long
      (i + 1).times do
        class_name, queue_name = class_names.sample
        worker = Resque::Worker.new(queue_name)
        resque_instance.resque_data_store.register_worker(worker)
        resque_instance.resque_data_store.set_worker_payload(
          worker,
          Resque.encode(
            queue: queue_name,
            run_at: (Time.now - 2.hours).utc.iso8601,
            payload: { class: class_name, args: [4, 5, 6] }
          )
        )
      end

      # make waiting
      ((i + 2) * 3).times do
        class_name, queue_name = class_names.sample
        resque_instance.resque_data_store.push_to_queue(queue_name, Resque.encode(class: class_name, args: [i, 'foo']))
      end

      empty_queue = empty_queues.sample
      resque_instance.resque_data_store.push_to_queue(empty_queue, {})
      resque_instance.resque_data_store.pop_from_queue(empty_queue)
    end
  end
end
