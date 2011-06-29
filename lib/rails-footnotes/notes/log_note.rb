module Footnotes
  module Notes
    class LogNote < AbstractNote
      @@log = []

      def self.close!(controller)
        @@log = []
      end

      def self.log(message)
        @@log << message
      end

      def initialize(controller)
        @controller = controller
      end

      def title
        "Log (#{log.count("\n")})"
      end

      def content
        escape(log.gsub(/\e\[.+?m/, '')).gsub("\n", '<br />')
      end

      def log
        unless @log
          @log = @@log.join('')
          if rindex = @log.rindex('Processing '+@controller.class.name+'#'+@controller.action_name)
            @log = @log[rindex..-1]
          end
        end
        @log
      end

      module LoggingExtensions
        def add(*args, &block)
          logged_message = super
          Footnotes::Notes::LogNote.log(logged_message)
          logged_message
        end
      end

      Rails.logger.extend LoggingExtensions
    end
  end
end

