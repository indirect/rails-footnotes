require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class ViewNote < AbstractNote
      def initialize(controller)
        @controller = controller
        @template = controller.instance_variable_get('@template')
      end

      def row
        :edit
      end

      def link
        escape(Footnotes::Filter.prefix + filename)
      end

      def valid?
        prefix? && first_render?
      end

      protected
        def first_render?
          @template.__send__(:_first_render)
        end
        
        def filename
          @filename ||= @template.__send__(:_first_render).filename
        end
    end
  end
end