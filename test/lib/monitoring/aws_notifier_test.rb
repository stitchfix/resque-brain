describe Monitoring::AwsNotifier, 'AWS CloudWatch Notifications' do
  def generate_payload(resque_name:, check_scope:, check_name:, check_count:)
    {
      namespace: "StitchFix/iZombie",
      metric_data: [{
        metric_name: "iz-job-queue-depth",
        dimensions: [
          {
            name: 'app',
            value: resque_name
          }, {
            name: "queue",
            value: check_scope
          }, {
            name: "status",
            value: check_name.split('.')[1],
          }
        ],
        timestamp: Time.now,
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

  before do
    @cloudwatch = Aws::CloudWatch::Client.new(stub_responses: true)
    @notifier = Monitoring::AwsNotifier.new(cloudwatch: @cloudwatch)
  end

  it "should record cloudwatch metrics" do
    @cloudwatch.expects(:put_metric_data).with(generate_payload(resque_name: 'test1', check_scope: 'queue_name', check_name: 'foo.bar', check_count: 3))
    @cloudwatch.expects(:put_metric_data).with(generate_payload(resque_name: 'test2', check_scope: 'queue_name', check_name: 'foo.bar', check_count: 1))
    @cloudwatch.expects(:put_metric_data).with(generate_payload(resque_name: 'test`', check_scope: 'queue2_name', check_name: 'foo.bar', check_count: 0))
    @notifier.notify!([
      Monitoring::CheckResult.new(resque_name: "test1", scope: 'queue_name', check_name: "foo.bar", check_count: 3),
      Monitoring::CheckResult.new(resque_name: "test2", scope: 'queue_name', check_name: "foo.bar", check_count: 1),
      Monitoring::CheckResult.new(resque_name: "test1", scope: 'queue2_name', check_name: "foo.bar", check_count: 0),
    ])
  end
end
