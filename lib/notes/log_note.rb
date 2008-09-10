require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class LogNote < AbstractNote
      def initialize(controller)
        @controller = controller
      end

      def content
        escape(log_tail).gsub("\n","<br />")
      end

      protected
        def log_tail
          filename = if RAILS_DEFAULT_LOGGER.instance_variable_get('@log')
            RAILS_DEFAULT_LOGGER.instance_variable_get('@log').path
          else 
            RAILS_DEFAULT_LOGGER.instance_variable_get('@logdev').filename
          end
          file_string = File.open(filename).read.to_s

          # We try to select the specified action from the log
          # If we can't find it, we get the last 100 lines
          #
          if rindex = file_string.rindex('Processing '+@controller.controller_class_name+'#'+@controller.action_name)
            file_string[rindex..-1].gsub(/\e\[.+?m/, '')
          else
            lines = file_string.split("\n")
            index = [lines.size-100,0].max
            lines[index..-1].join("\n")
          end
        end
    end
  end
end