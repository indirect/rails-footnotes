module Footnotes
  module Notes
    class LogNote < AbstractNote

      autoload :NoteLogger, 'rails-footnotes/notes/log_note/note_logger'

      thread_cattr_accessor :logs
      thread_cattr_accessor :original_logger

      def self.start!(controller)
        self.logs = []
        self.original_logger = Rails.logger
        note_logger = NoteLogger.new(self.logs)
        note_logger.level = self.original_logger.level
        note_logger.formatter =
          if self.original_logger.kind_of?(Logger)
            self.original_logger.formatter
          else
            defined?(ActiveSupport::Logger) ? ActiveSupport::Logger::SimpleFormatter.new : Logger::SimpleFormatter.new
          end

        if ::Rails::VERSION::STRING < "7.1"
          ::Rails.logger.extend(::ActiveSupport::Logger.broadcast(note_logger))
        else
          ::Rails.logger = ::ActiveSupport::BroadcastLogger.new(::Rails.logger, note_logger)
        end
      end

      def title
        "Log (#{log.count})"
      end

      def content
        result = '<table>'
          log.compact.each do |l|
            result += "<tr><td>#{l.gsub(/\e\[.+?m/, '')}</td></tr>"
          end
        result += '</table>'
        # Restore formatter
        Rails.logger = self.class.original_logger
        result
      end

      def log
        self.class.logs
      end

    end
  end
end
