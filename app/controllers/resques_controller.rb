class ResquesController < ApplicationController
  include Concerns::InjectibleResqueInstances

  def index
    @resques = resques.all.sort_by { |resque| resque.name.downcase }
  end

  def show
    @resque = resque(param_name: :id)
  end
end
