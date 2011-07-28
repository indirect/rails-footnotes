module Footnotes
  module Notes
    class CookiesNote < AbstractNote
      def initialize(controller)
        @cookies = controller.request.env["rack.request.cookie_hash"].nil? ? {} : controller.request.env["rack.request.cookie_hash"].dup
      end

      def title
        "Cookies (#{@cookies.length})"
      end

      def content
        mount_table_for_hash(@cookies, :summary => "Debug information for #{title}")
      end
    end
  end
end
