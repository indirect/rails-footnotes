module Footnotes
  module Notes
    class EnvNote < AbstractNote
      def initialize(controller)
        @env = controller.request.env.dup
      end

      def content
        env_data = @env.map { |k, v|
          case k
          when 'HTTP_COOKIE'
            # Replace HTTP_COOKIE for a link
            [k.to_s, '<a href="#" style="color:#009" onclick="Footnotes.hideAllAndToggle(\'cookies_debug_info\');return false;">See cookies on its tab</a>']
          else
            [k.to_s, escape(v.to_s)]
          end
        }.sort.unshift([ :key, escape('value') ])

        # Create the env table
        mount_table(env_data)
      end
    end
  end
end
