require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class EnvNote < AbstractNote
      def initialize(controller)
        @env = controller.request.env.dup
      end

      def title
        'Env'
      end

      def content
        @env['HTTP_COOKIE'] = '<a href="#" style="color:#009" onclick="footnotes_toogle(\'cookies_debug_info\');return false;" />See cookies on its tab</a>'
        mount_table(@env.to_a.sort.unshift([:key, :value]))
      end
    end
  end
end
