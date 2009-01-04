require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class SessionNote < AbstractNote
      def initialize(controller)
        @session = (controller.session.instance_variable_get("@data") || {}).symbolize_keys
      end

      def content
        escape(@session.inspect)
      end
    end
  end
end