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
      
      def title
        "View"
      end
      
      def link
        escape(Footnotes::Filter.prefix(filename, 1, 1))
      end

      def valid?
        prefix? && filename.present?
      end

      protected
        def filename
          @filename ||= begin
            full_filename = nil
            log.split("\n").each do |line|
              next if line !~ /Rendered (\S*) within/
              
              file = line[/Rendered (\S*) within/, 1]
              @controller.view_paths.each do |view_path|
                path = File.join(view_path.to_s, "#{file}*")
                full_filename ||= Dir.glob(path).first
              end
            end
            full_filename
          end
        end

    end
  end
end
