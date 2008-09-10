require "#{File.dirname(__FILE__)}/view_note"

module Footnotes
  module Notes
    class LayoutNote < AbstractNote
      def initialize(controller)
        @controller = controller
        @template = controller.instance_variable_get('@template')
      end

      def row
        :edit
      end

      def link
        escape(Footnotes::Filter.prefix + layout_filename)
      end

      def valid?
        prefix? && @controller.active_layout && layout_template
      end

      protected
        def layout_template
          @layout_template ||= @template.__send__(:_pick_template, @controller.active_layout)
        end

        def layout_filename
          layout_template.filename
        end
    end
  end
end