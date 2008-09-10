require "#{File.dirname(__FILE__)}/files_note"

module Footnotes
  module Notes
    class JavascriptsNote < FilesNote
      def title
        "Javascripts (#{@files.length})"
      end

      protected
        def scan_text(text)
          text.scan(/<script[^>]+src\s*=\s*['"]([^>?'"]+\.js)/im).flatten
        end
    end
  end
end