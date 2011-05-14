module Footnotes
  module Notes
    class LayoutNote < AbstractNote
      def initialize(controller)
        @controller = controller
      end

      def row
        :edit
      end

      def link
        escape(Footnotes::Filter.prefix(filename, 1, 1))
      end

      def valid?
        prefix? && nil#@controller.active_layout TODO doesn't work with Rails 3
      end

      protected
        def filename
          File.join(File.expand_path(Rails.root), 'app', 'layouts', "#{@controller.active_layout.to_s.underscore}").sub('/layouts/layouts/', '/views/layouts/')
        end
    end
  end
end
