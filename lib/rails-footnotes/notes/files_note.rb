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
          "<ul><li>#{@files.join("</li><li>")}</li></ul>"
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
          if Rails::VERSION::STRING.to_f >= 3.1 && Rails.application.config.assets[:enabled]
            asset_paths = Rails.application.config.assets.paths
            linked_files = []
            
            @files.collect do |file|
              asset_paths.each do |asset_path|
                file_path = file.sub('/assets', asset_path)
                file_name = file_path.match(/^.*\/(.*)$/)[1]
                if File.exist? file_path
                  linked_files << %[<a href="#{Footnotes::Filter.prefix(file_path, 1, 1)}">#{file_name}</a>]
                end
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
