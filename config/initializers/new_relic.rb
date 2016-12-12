if ENV["USE_NEWRELIC"] == "true"
  Rails.logger.info "Requiring New Relic"
  require "newrelic_rpm"
else
  Rails.logger.info "Not requiring New Relic"
end
