module Footnotes
  module Extensions
    module Exception
      def self.included(base)
        base.class_eval do
          alias_method_chain :clean_backtrace, :links
        end
      end

      def add_links_to_backtrace(lines)
        lines.collect do |line|
          expanded = line.gsub('#{RAILS_ROOT}', RAILS_ROOT)
          if match = expanded.match(/^(.+):(\d+):in/) || match = expanded.match(/^(.+):(\d+)\s*$/)
            file = File.expand_path(match[1])
            line_number = match[2]
            html = %[<a href="#{Footnotes::Filter.prefix(file, line_number, 1)}">#{line}</a>]
          else
            line
          end
        end
      end

      def clean_backtrace_with_links
        unless ::Footnotes::Filter.prefix.blank?
          add_links_to_backtrace(clean_backtrace_without_links)
        else
          clean_backtrace_without_links
        end
      end
    end
  end
end

Exception.send :include, Footnotes::Extensions::Exception