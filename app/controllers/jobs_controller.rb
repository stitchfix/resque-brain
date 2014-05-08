class JobsController < ApplicationController

  cattr_accessor :resques, instance_writer: false do
    RESQUES
  end

  def running
    @jobs = resques.find(params[:resque_id]).jobs_running.sort_by { |job| job.queue }
  end

  def waiting
    @jobs_waiting_by_queue = resques.find(params[:resque_id]).jobs_waiting
  end
end
