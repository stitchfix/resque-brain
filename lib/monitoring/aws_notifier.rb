require_relative 'notifier'

module Monitoring
  class AwsNotifier < Notifier
    def initialize(cloudwatch: Aws::CloudWatch::Client.new)
      @cloudwatch = cloudwatch
    end

    def notify!(check_results)
      check_results.each do |check_result|
        source = [check_result.resque_name,check_result.scope].compact.join(".")
        log_to_cloudwatch(
          app: check_result.resque_name,
          queue: "#{check_result.scope}",
          count: check_result.check_count,
          state: check_result.check_name.split('.')[1]
        )
      end
    end

  protected

    def log_to_cloudwatch(app:, queue:, count:, state:)
      @cloudwatch.put_metric_data({
        namespace: "StitchFix/iZombie",
        metric_data: [{
          metric_name: "iz-job-queue-depth",
          dimensions: [
            {
              name: 'app',
              value: app
            }, {
              name: 'status',
              value: state
            }, {
              name: "queue",
              value: queue
            }
          ],
          timestamp: Time.now,
          value: count,
          statistic_values: {
            sample_count: 1.0,
            sum: count,
            minimum: count,
            maximum: count,
          },
          unit: "Count"
        }]
      })
    end

  end
end
