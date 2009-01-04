require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class CookiesNote < AbstractNote
      def initialize(controller)
        @cookies = (controller.__send__(:cookies) || {}).symbolize_keys
      end

      def title
        "Cookies (#{@cookies.length})"
      end

      def content
        escape(@cookies.inspect)
      end
    end
  end
end