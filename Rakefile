# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task :schedule_background_jobs do
  Resque.schedule = YAML.load_file("#{Rails.root}/config/scheduler.yml")
end
task :'resque:scheduler' => :schedule_background_jobs
