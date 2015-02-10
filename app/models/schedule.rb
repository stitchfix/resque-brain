class Schedule

  attr_reader :name
  attr_reader :klass
  attr_reader :queue
  attr_reader :description
  attr_reader :every
  attr_reader :args

  def initialize(attributes={})
    @name            = attributes[:name]
    @args            = attributes[:args]
    @klass           = attributes[:klass]
    @queue           = attributes[:queue]
    @description     = attributes[:description]
    @every           = attributes[:every]
    @cron_expression = CronExpression.new(attributes[:cron])
  end

  # The cron expression for this schedule
  def cron
    @cron_expression.original_expression
  end

  # A human-description of the cron
  def frequency_in_words
    @cron_expression.frequency_in_words
  end

  class CronExpression
    attr_reader :original_expression

    def initialize(expression)
      @original_expression = expression
    end

    def frequency_in_words
      @frequency_in_words ||= begin
                                cron_parts = String(@original_expression).split(/\s/)
                                (Cron2English.parse(cron(cron_parts)).join(' ') + " #{timezone(cron_parts)}").strip
                              rescue Exception # sign, Cron2English throws friggin' Exception
                              end
    end

  private

    def cron(cron_parts)
      cron_parts[0..4].join(" ")
    end

    def timezone(cron_parts)
      if cron_parts[5].blank?
        cron_parts[5]
      else
        Time.now.in_time_zone(cron_parts[5]).strftime("%Z") rescue nil
      end
    end
  end
end
