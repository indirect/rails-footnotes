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
          if Rails.version >= '3.1' && Rails.application.config.assets[:enabled]
            asset_paths = Rails.application.config.assets.paths
            linked_files = []

            @files.collect do |file|
              base_name = File.basename(file)
              asset_paths.each do |asset_path|
                results = Dir[File.expand_path(base_name, asset_path) + '*']
                results.each do |r|
                  linked_files << %[<a href="#{Footnotes::Filter.prefix(r, 1, 1)}">#{File.basename(r)}</a>]
                end
                break if results.present?
              end
            end
            @files = linked_files
          else
            #Original Implementation
            @files.collect! do |filename|
              if filename =~ %r{^/}
                full_filename = File.join(File.expand_path(Rails.root), 'public', filename)
                %[<a href="#{Footnotes::Filter.prefix(full_filename, 1, 1)}">#{filename}</a>]
              else
                %[<a href="#{filename}">#{filename}</a>]
              end
            end
          end
        end
    end
  end
end
