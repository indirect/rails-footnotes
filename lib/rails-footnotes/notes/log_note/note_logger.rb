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

        ## Backport from rails 4 for handling logging broadcast, should be removed when rails 3 is deprecated :

        # Broadcasts logs to multiple loggers.
        def self.broadcast(logger) # :nodoc:
          Module.new do
            define_method(:add) do |*args, &block|
              logger.add(*args, &block)
              super(*args, &block)
            end

            define_method(:<<) do |x|
              logger << x
              super(x)
            end

            define_method(:close) do
              logger.close
              super()
            end

            define_method(:progname=) do |name|
              logger.progname = name
              super(name)
            end

            define_method(:formatter=) do |formatter|
              logger.formatter = formatter
              super(formatter)
            end

            define_method(:level=) do |level|
              logger.level = level
              super(level)
            end
          end
        end

      end
    end
  end
end
