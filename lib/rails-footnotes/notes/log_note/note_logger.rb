module Footnotes
  module Notes
    class LogNote
      class NoteLogger < Logger

        def initialize(logs)
          @logs = logs
        end

        def add(severity, message = nil, progname = nil, &block)
          severity ||= UNKNOWN
          if severity < level
            return true
          end
          formatter = @formatter || Logger::Formatter.new
          @logs << formatter.call(format_severity(severity), Time.now, message, progname)
        end

      end
    end
  end
end
