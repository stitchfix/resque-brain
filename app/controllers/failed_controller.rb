class FailedController < ApplicationController
  include Concerns::InjectibleResqueInstances
  skip_before_filter :verify_authenticity_token

  def index
    start = params[:start].to_i
    count = params[:count].try(:to_i) || :all
    @jobs_failed = resque.jobs_failed(start,count)
  end

  def show
    @job = resque.jobs_failed(params[:id].to_i,1).first
  end

  def retry
    resque.retry_job(params[:id].to_i)
    render nothing: true, status: 204
  end

end
