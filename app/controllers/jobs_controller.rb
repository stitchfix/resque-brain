class JobsController < ApplicationController
  include Concerns::InjectibleResqueInstances

  def running
    @jobs = resque.jobs_running.sort_by { |job| job.queue }
  end

  def waiting
    if params[:count_only] == 'true'
      @jobs_waiting_by_queue = resque.waiting_by_queue
      render :waiting_counts_only
    else
      @jobs_waiting_by_queue = resque.jobs_waiting
    end
  end
end
