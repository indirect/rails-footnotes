require "#{File.dirname(__FILE__)}/abstract_note"

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
        prefix? && @controller.active_layout
      end

      protected
        def filename
          File.join(File.expand_path(RAILS_ROOT), 'app', 'layouts', "#{@controller.active_layout.to_s.underscore}").sub('/layouts/layouts/', '/views/layouts/')
        end
    end
  end
end
