class FailedController < ApplicationController

  cattr_accessor :resques, instance_writer: false do
    RESQUES
  end

  def index
    start = params[:start].to_i
    count = params[:count].try(:to_i) || :all
    @jobs_failed = resques.find(params[:resque_id]).jobs_failed(start,count)
  end

  def retry
    resques.find(params[:resque_id]).retry_job(params[:id].to_i)
    render nothing: true, status: 204
  end

end
