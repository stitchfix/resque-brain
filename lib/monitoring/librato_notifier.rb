# frozen_string_literal: true

require_relative 'notifier'

module Monitoring
  class LibratoNotifier < Notifier
    def initialize(logger: Rails.logger, type: :count, unit: '')
      @logger = logger
      @type   = type
      @unit   = unit || ''
    end

    # Log metrics based on the hash passed in.
    #
    # results:: a hash where the keys represent the source (the resque instance name) and the values
    #           are lists of items to be counted.  The items won't be examined, just counted and used in the metric
    def notify!(check_results)
      check_results.each do |check_result|
        source = [check_result.resque_name, check_result.scope].compact.join('.')
        log_to_librato(source, @type, check_result.check_name, check_result.check_count)
      end
    end

    protected

    def log_to_librato(source, type, prefix, size)
      @logger.info("source=#{source} #{type}##{prefix}=#{size}#{@unit}")
    end

    private

    def validate_prefix!(prefix)
      raise ArgumentError, 'You must supply a prefix' if String(prefix).strip == ''
      raise ArgumentError, 'prefix should only have numbers, letters, and dots' unless prefix =~ /^[0-9_a-zA-Z\-\.]+$/
      prefix
    end
  end
end
