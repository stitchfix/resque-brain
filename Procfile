web: bundle exec puma -C config/puma.rb
resque_scheduler: env NEW_RELIC_DISPATCHER=resque TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake environment resque:scheduler
monitor_worker: env NEW_RELIC_DISPATCHER=resque TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 bundle exec rake environment resqutils:work QUEUE=monitor --trace
