class ResquesController < ApplicationController
  def index
    @resques = ResqueInstance.all
  end

  def show
  end
end
