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
      end

      def row
        :edit
      end

      def title
        "View (#{"%.3f" % self.template[:duration]}ms)"
      end

      def link
        escape(Footnotes::Filter.prefix(filename, 1, 1))
      end

      def valid?
        prefix? && filename && File.exists?(filename)
      end

      protected

        def filename
          @filename ||= self.class.template[:file]
        end

    end
  end
end
