class SchedulesController < ApplicationController
  include Concerns::InjectibleResqueInstances
  skip_before_filter :verify_authenticity_token

  def show
    @schedule = resque.schedule
  end

end
