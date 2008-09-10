require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class EnvNote < AbstractNote
      def initialize(controller)
        @env = controller.request.env.dup
      end

      def content
        # Replace HTTP_COOKIE for a link
        @env['HTTP_COOKIE'] = '<a href="#" style="color:#009" onclick="footnotes_toogle(\'cookies_debug_info\');return false;" />See cookies on its tab</a>'

        # Create the env table
        mount_table(@env.to_a.sort.unshift([:key, :value]))
      end
    end
  end
end
