require 'ostruct'
module Monitoring
  class FailedJobByClassCheck < Monitoring::Checker
    def check!
      @resques.all.map { |resque_instance|
        by_class = resque_instance.jobs_failed.group_by { |job| job.payload["class"] || "NoClass" }
        by_class.keys.sort.map { |class_name|
          CheckResult.new(resque_name: resque_instance.name,
                          check_name: "resque.failed_jobs",
                          scope: class_name.parameterize,
                          check_count: by_class[class_name].size)
        }
      }.flatten.compact
    end
  end
end
