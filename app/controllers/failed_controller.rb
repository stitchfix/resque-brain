class FailedController < ApplicationController

  cattr_accessor :resques, instance_writer: false do
    RESQUES
  end

  def index
    @jobs_failed = resques.find(params[:resque_id]).jobs_failed.sort_by { |job|
      job.failed_at.to_i
    }.reverse
  end

end
