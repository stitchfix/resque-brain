# frozen_string_literal: true

class SchedulesController < ApplicationController
  include Concerns::InjectibleResqueInstances
  skip_before_action :verify_authenticity_token

  def show
    @schedule = resque.schedule.sort_by(&:name)
  end

  def queue
    job = resque.schedule.detect { |schedule_element| schedule_element.name == params[:job_name] }
    if job.present?
      resque.queue_job_from_schedule(job)
      render nothing: true, status: 201
    else
      render text: "No such job named #{params[:job_name]}", status: 404
    end
  end
end
