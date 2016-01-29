module Monitoring
  class Checker
    def initialize(resques: RESQUES)
      @resques = resques
    end
    # Should return an array of CheckResult representing the results of the check
    def check!
      raise
    end
  end
end
