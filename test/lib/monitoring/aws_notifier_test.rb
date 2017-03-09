require 'quick_test_helper'
require 'minitest/autorun'
require 'mocha/setup'

lib_require 'monitoring/aws_notifier'
lib_require 'monitoring/check_result'

module Monitoring
end
class Monitoring::AwsNotifierTest < MiniTest::Test
  include Mocha::API

  def test_should_record_cloudwatch_metrics
    cloudwatch = Aws::CloudWatch::Client.new(stub_responses: true)
    notifier = Monitoring::AwsNotifier.new(cloudwatch: cloudwatch, namespace: "Foobar", metric_name: "blah")

    now = Time.now
    time_zone = Object.new
    Time.expects(:zone).at_least_once.returns(time_zone)
    time_zone.expects(:now).at_least_once.returns(now)

    cloudwatch.expects(:put_metric_data).with(generate_payload(resque_name: 'test1', check_scope: 'queue_name1', check_name: 'foo.bar', check_count: 3, now: now))
    cloudwatch.expects(:put_metric_data).with(generate_payload(resque_name: 'test2', check_scope: 'queue_name2', check_name: 'foo.bar', check_count: 1, now: now))
    cloudwatch.expects(:put_metric_data).with(generate_payload(resque_name: 'test3', check_scope: 'queue_name3', check_name: 'foo.bar', check_count: 0, now: now))
    notifier.notify!([
      Monitoring::CheckResult.new(resque_name: "test1", scope: 'queue_name1', check_name: "foo.bar", check_count: 3),
      Monitoring::CheckResult.new(resque_name: "test2", scope: 'queue_name2', check_name: "foo.bar", check_count: 1),
      Monitoring::CheckResult.new(resque_name: "test3", scope: 'queue_name3', check_name: "foo.bar", check_count: 0),
    ])

    mocha_verify
  end

private

  def generate_payload(resque_name:, check_scope:, check_name:, check_count:, now:)
    {
      namespace: "Foobar",
      metric_data: [{
        metric_name: "blah",
        dimensions: [
          {
            name: 'app',
            value: resque_name
          }, {
            name: "status",
            value: check_name.split('.')[1],
          }, {
            name: "queue",
            value: check_scope
          }
        ],
        timestamp: now,
        value: check_count,
        statistic_values: {
          sample_count: 1.0,
          sum: check_count,
          minimum: check_count,
          maximum: check_count,
        },
        unit: "Count"
      }]
    }
  end

end
