require 'ostruct'
module Monitoring
  class FailedJobByClassCheck < Monitoring::Checker
    def check!
      super.flatten.compact
    end

  private

    def do_check(resque_instance)
      by_class = resque_instance.jobs_failed.group_by { |job| job.payload["class"] || "NoClass" }
      by_class.keys.sort.map { |class_name|
        CheckResult.new(resque_name: resque_instance.name,
                        check_name: "resque.failed_jobs",
                        scope: class_name.parameterize,
                        check_count: by_class[class_name].size)
      }
    end
  end
end
