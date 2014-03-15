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
        note_logger.formatter = self.original_logger.formatter
        Rails.logger = self.original_logger.dup.extend(ActiveSupport::Logger.broadcast(note_logger))
      end

      def title
        "Log (#{log.count("\n")})"
      end

      def content
        result = escape(log.gsub(/\e\[.+?m/, '')).gsub("\n", '<br />')
        # Restore formatter
        Rails.logger = self.class.original_logger
        result
      end

      def log
        self.class.logs.join("\n")
      end

    end
  end
end
