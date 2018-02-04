require 'pry'
module Footnotes
  module Notes
    class FilesNote < AbstractNote
      def initialize(controller)
        @files = scan_text(controller.response.body)
        parse_files!
      end

      def row
        :edit
      end

      def content
        if @files.empty?
          ""
        else
          "<ul><li>%s</li></ul>" % @files.join("</li><li>")
        end
      end

      def valid?
        prefix?
      end

      protected
        def scan_text(text)
          []
        end

        def parse_files!
          linked_files = []

          @files.collect do |file|
            base_name = File.basename(file)
            parts = base_name.split("-")
            undigest_name = if parts.size > 1
              parts.pop
              parts.join("-") + File.extname(base_name)
            else
              base_name
            end

            if Rails.application.assets_manifest.find_sources(undigest_name).any?
              filename = Rails.application.assets[undigest_name].filename
              linked_files << %[<a href="#{Footnotes::Filter.prefix(filename, 1, 1)}">#{File.basename(filename)}</a>]
            end

          end
          @files = linked_files
        end
    end
  end
end
