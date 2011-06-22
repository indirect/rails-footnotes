module Footnotes
  module Notes
    class ViewNote < LogNote
      def initialize(controller)
        super
        @controller = controller
      end

      def row
        :edit
      end

      def link
        escape(Footnotes::Filter.prefix(filename, 1, 1))
      end

      def valid?
        prefix?
      end

      protected
        def filename
          @filename ||= begin
            log_lines = log
            log_lines.split("\n").map do |line|
              if line =~ /Rendered (\S*) \(([\d\.]+)\S*?\)/ && $1.split("/").last !~ /\A_/
                file = $1
                @controller.view_paths.each do |view_path|
                  path = File.join(view_path.to_s, "#{file}*")
                  files = Dir.glob(path)
                  files.first
                end
              end
            end.first
          end
        end

    end
  end
end
