worker_processes Integer(ENV["WEB_CONCURRENCY"] || 4)
timeout 35 # let Heroku terminate the request, but ensure unicorn kills the process
preload_app true

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  #defined?(Resque) and Resque.redis.quit
end 

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.execute("set application_name = '#{Rails.application.class.parent.to_s}'")
  end

  #if defined?(Resque)
  #  load File.join(Rails.root,'config','initializers','resque.rb')
  #end
end
