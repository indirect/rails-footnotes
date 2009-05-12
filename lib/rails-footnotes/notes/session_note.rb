require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class SessionNote < AbstractNote
      def initialize(controller)
        @session = (controller.session || {}).symbolize_keys
      end

      def title
        "Session (#{@session.length})"
      end

      def content
        mount_table_for_hash(@session)
      end
    end
  end
end
