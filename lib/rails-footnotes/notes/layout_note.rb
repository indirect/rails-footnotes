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
          @controller.active_layout.filename
        end
    end
  end
end
