class WorkersController < ApplicationController
  cattr_accessor :resques, instance_writer: false do
    RESQUES
  end

  def destroy
    resques.find(params[:resque_id]).kill_worker(params[:id])
    render nothing: true, status: 204
  end
end
