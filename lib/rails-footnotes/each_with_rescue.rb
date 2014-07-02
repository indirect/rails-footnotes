module Footnotes
  module EachWithRescue
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      # Process notes, discarding only the note if any problem occurs
      #
      def each_with_rescue(collection)
        delete_me = []

        collection.each do |item|
          begin
            yield item
          rescue Exception => e
            raise e if Rails.env.test?
            # Discard item if it has a problem
            log_error("Footnotes #{item.to_s.camelize} Exception", e)
            delete_me << item
            next
          end
        end

        delete_me.each { |item| collection.delete(item) }
        return collection
      end

      # Logs the error using specified title and format
      #
      def log_error(title, exception)
        Rails.logger.error "#{title}: #{exception}\n#{exception.backtrace.join("\n")}"
      end
    end
  end
end
