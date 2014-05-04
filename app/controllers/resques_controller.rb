class ResquesController < ApplicationController
  def index
    @resques = ResqueInstance.all
  end

  def show
    @resque = ResqueInstance.find(params[:id])
    if @resque.nil?
      render :file => "#{Rails.root}/public/404.html",  :status => 404
    end
  end
end
