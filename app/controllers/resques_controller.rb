class ResquesController < ApplicationController
  include Concerns::InjectibleResqueInstances

  def index
    @resques = resques.all
  end

  def show
    @resque = resque(param_name: :id)
  end
end
