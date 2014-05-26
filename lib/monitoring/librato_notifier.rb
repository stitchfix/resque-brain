module Monitoring
  class LibratoNotifier < Notifier
    def initialize(prefix: nil, logger: Rails.logger, type: :count)
      @prefix = validate_prefix!(prefix)
      @logger = logger
      @type = type
    end

    def notify!(results)
      results.each do |resque_name,items|
        @logger.info("source=#{resque_name} #{@type}##{@prefix}=#{items.size}")
      end
    end

  private

    def validate_prefix!(prefix)
      raise ArgumentError,"You must supply a prefix" if String(prefix).strip == ''
      raise ArgumentError,"prefix should only have numbers, letters, and dots" unless prefix =~/^[0-9_a-zA-Z\-\.]+$/
      prefix
    end
  end
end
