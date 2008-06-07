require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class FilesNote < AbstractNote
      def initialize(controller)
        body = controller.response.body
        @files = body.is_a?(String) ? scan_text(body) : []
        parse_files!
      end

      def self.to_sym
        :files
      end

      def row
        :edit
      end

      def content
        "<ul><li>#{@files.join("</li><li>")}</li></ul>"
      end

      def valid?
        prefix?
      end

      protected
        def scan_text(text)
          []
        end

        def parse_files!
          @files.collect! do |filename|
            if filename =~ %r{^/}
              full_filename = File.join(File.expand_path(RAILS_ROOT), 'public', filename)
              %{<a href="#{Footnotes::Filter.prefix}#{full_filename}">#{filename}</a>}
            else
              %{<a href="#{filename}">#{filename}</a>}
            end
          end
        end
    end
  end
end