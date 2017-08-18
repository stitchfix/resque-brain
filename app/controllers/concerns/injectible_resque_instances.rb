# frozen_string_literal: true

module Concerns
  module InjectibleResqueInstances
    extend ActiveSupport::Concern

    included do
      cattr_accessor :resques, instance_writer: false do
        RESQUES
      end
    end

    def resque(param_name: :resque_id)
      resques.find(params[param_name]).tap do |resque_instance|
        if resque_instance.nil?
          raise NoSuchResque.new(param_name, params[param_name])
        end
      end
    end
  end
end
