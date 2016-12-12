web: env USE_NEWRELIC=true bundle exec puma -C config/puma.rb
resque_scheduler: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake environment resque:scheduler
monitor_worker: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake environment resqutils:work QUEUE=monitor --trace

# The cleanup jobs should go to their own queue, because race condition :)
worker_killer_worker: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake environment resqutils:work QUEUE=worker_killer_job --trace

