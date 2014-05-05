class ResquesController < ApplicationController
  def index
    @resques = ResqueInstance.all
    @resques.each do |resque|
      Rails.logger.info "Resque: #{resque.name} configured for #{resque.resque_data_store}"
    end
  end

  def show
    @resque = ResqueInstance.find(params[:id])
    if @resque.nil?
      render :file => "#{Rails.root}/public/404.html",  :status => 404
    end
  end
end
