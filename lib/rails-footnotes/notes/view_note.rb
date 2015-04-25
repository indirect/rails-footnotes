module Footnotes
  module Notes
    class ViewNote < AbstractNote
      cattr_accessor :template

      def self.start!(controller)
        @subscriber ||= ActiveSupport::Notifications.subscribe('render_template.action_view') do |*args|
          event = ActiveSupport::Notifications::Event.new *args
          self.template = {:file => event.payload[:identifier], :duration => event.duration}
        end
      end

      def initialize(controller)
        @controller = controller
        @template = controller.instance_variable_get(:@template)
      end

      def row
        :edit
      end

      def link
        escape(Footnotes::Filter.prefix(filename, 1, 1))
      end

      def valid?
        prefix? && first_render?
      end

      protected

        def first_render?
          @template.instance_variable_get(:@_first_render)
        end

        def filename
          @filename ||= @template.instance_variable_get(:@_first_render).filename
        end

    end
  end
end
