require_relative 'notifier'

module Monitoring
  class StatsdNotifier < Notifier
    def initialize(statsd: STATSD)
      @statsd = statsd
    end
    def notify!(check_results)
      check_results.each do |check_result|
        metric_name = check_result.check_name
        tags = [ "app:#{check_result.resque_name}" ]
        tags << "queue:#{check_result.scope}" if check_result.scope
        @statsd.gauge(metric_name,check_result.check_count,tags: tags)
      end
    end

  end
end
