module Footnotes
  module Notes
    class LogNote < AbstractNote

      autoload :NoteLogger, 'rails-footnotes/notes/log_note/note_logger'

      cattr_accessor :logs
      cattr_accessor :original_logger

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
        # Rails 3 don't have ActiveSupport::Logger#broadcast so we backported it
        extend_module = defined?(ActiveSupport::Logger) ? ActiveSupport::Logger.broadcast(note_logger) : NoteLogger.broadcast(note_logger)
        Rails.logger = self.original_logger.clone.extend(extend_module)
      end

      def title
        "Log (#{log.count})"
      end

      def content
        result = '<table>'
          log.compact.each do |l|
            result << "<tr><td>#{l.gsub(/\e\[.+?m/, '')}</td></tr>"
          end
        result << '</table>'
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
