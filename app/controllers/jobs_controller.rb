class JobsController < ApplicationController

  cattr_accessor :resques, instance_writer: false do
    RESQUES
  end

  def running
  end

  def waiting
  end
end
