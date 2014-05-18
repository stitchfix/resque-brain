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

  def destroy
    resque.clear_job(params[:id].to_i)
    render nothing: true, status: 204
  end

  def retry_all
    resque.retry_all
    resque.clear_all if params[:also_clear] == 'true'
    render nothing: true, status: 204
  end

  def clear_all
    resque.clear_all
    render nothing: true, status: 204
  end
end
