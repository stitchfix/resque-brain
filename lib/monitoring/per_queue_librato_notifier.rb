module Monitoring
  class PerQueueLibratoNotifier < LibratoNotifier
    # Log metrics based on the hash passed in, which is assumed to be organized by queue.
    #
    # results:: a hash where the keys represent the source (the resque instance name) and the values
    #           are themselves hashes.  The keys of *those* hashes are the names of queues, and their values
    #           are lists of items to be counted.  The items won't be examined, just counted and used in the metric
    def notify!(results)
      results.each do |resque_name,by_queue|
        by_queue.sort_by(&:to_s).each do |queue_name,items|
          log_to_librato(resque_name,@type,"#{@prefix}.#{queue_name}",items.size)
        end
      end
    end
  end
end
