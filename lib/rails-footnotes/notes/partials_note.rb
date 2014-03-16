module Footnotes
  module Notes
    class PartialsNote < AbstractNote

      cattr_accessor :partials

      def self.start!(controller)
        self.partials = []
        @subscriber ||= ActiveSupport::Notifications.subscribe('render_partial.action_view') do |*args|
          event = ActiveSupport::Notifications::Event.new *args
          self.partials << {:file => event.payload[:identifier], :duration => event.duration}
        end
      end

      def initialize(controller)
        @controller = controller
      end

      def row
        :edit
      end

      def title
        "Partials (#{partials.size})"
      end

      def content
        rows = self.class.partials.map do |partial|
          href = Footnotes::Filter.prefix(partial[:file],1,1)
          shortened_name = partial[:file].gsub(File.join(Rails.root,"app/views/"),"")
          [%{<a href="#{href}">#{shortened_name}</a>},"#{partial[:duration]}ms"]
        end
        mount_table(rows.unshift(%w(Partial Time)), :summary => "Partials for #{title}")
      end

    end
  end
end
