module Footnotes
  module Notes
    class CookiesNote < AbstractNote
      def initialize(controller)
        @cookies = Hash.new.update(controller.__send__(:cookies) || {}).symbolize_keys
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
