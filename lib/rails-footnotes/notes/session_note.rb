require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class SessionNote < AbstractNote
      def initialize(controller)
        session = controller.session
        if session
          if session.respond_to? :to_hash
            # rails >= 2.3
            session = session.to_hash
          else
            #rails < 2.3
            session = session.data
          end
        end
        @session = (session || {}).symbolize_keys
      end

      def title
        "Session (#{@session.length})"
      end

      def content
        mount_table_for_hash(@session, :summary => "Debug information for #{title}")
      end
    end
  end
end
