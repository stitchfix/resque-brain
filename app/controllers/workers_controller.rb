class WorkersController < ApplicationController
  include Concerns::InjectibleResqueInstances

  def destroy
    resque.kill_worker(params[:id])
    render nothing: true, status: 204
  end
end
