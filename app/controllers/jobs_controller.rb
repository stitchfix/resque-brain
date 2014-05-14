class JobsController < ApplicationController
  include Concerns::InjectibleResqueInstances

  def running
    @jobs = resque.jobs_running.sort_by { |job| job.queue }
  end

  def waiting
    @jobs_waiting_by_queue = resque.jobs_waiting
  end
end
