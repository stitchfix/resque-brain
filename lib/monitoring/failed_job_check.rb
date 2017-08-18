# frozen_string_literal: true

require 'ostruct'
require_relative 'checker'
module Monitoring
  class FailedJobCheck < Monitoring::Checker
    private

    def do_check(resque_instance)
      CheckResult.new(resque_name: resque_instance.name,
                      check_name: 'resque.failed_jobs',
                      check_count: resque_instance.failed)
    end
  end
end
