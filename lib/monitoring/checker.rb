# frozen_string_literal: true

module Monitoring
  class Checker
    def initialize(resques: RESQUES)
      @resques = resques
    end

    # Should return an array of CheckResult representing the results of the check
    def check!
      @resques.all.map do |resque_instance|
        check_one_resque(resque_instance)
      end
    end

    private

    def check_one_resque(resque_instance)
      do_check(resque_instance)
    rescue => ex
      raise Monitoring::WrappedException.new(resque_instance.name, ex)
    end
  end
end
