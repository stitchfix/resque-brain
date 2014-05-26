module Monitoring
  class LibratoNotifier < Notifier
    def initialize(prefix: nil, logger: Rails.logger, type: :count)
      @prefix = validate_prefix!(prefix)
      @logger = logger
      @type = type
    end

    # Log metrics based on the hash passed in.
    #
    # results:: a hash where the keys represent the source (the resque instance name) and the values
    #           are lists of items to be counted.  The items won't be examined, just counted and used in the metric
    def notify!(results)
      results.each do |resque_name,items|
        log_to_librato(resque_name,@type,@prefix,items.size)
      end
    end

  protected

    def log_to_librato(resque_name,type,prefix,size)
      @logger.info("source=#{resque_name} #{type}##{prefix}=#{size}")
    end

  private

    def validate_prefix!(prefix)
      raise ArgumentError,"You must supply a prefix" if String(prefix).strip == ''
      raise ArgumentError,"prefix should only have numbers, letters, and dots" unless prefix =~/^[0-9_a-zA-Z\-\.]+$/
      prefix
    end
  end
end
