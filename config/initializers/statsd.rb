require 'datadog/statsd'
STATSD = Datadog::Statsd.new(
  ENV['DD_AGENT_PORT_8126_TCP_ADDR'],
  (ENV['DD_AGENT_STATSD_PORT'] || 8125).to_i,
  {namespace: ENV["DD_AGENT_NAMESPACE"]})
