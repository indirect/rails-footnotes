require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class AssignsNote < AbstractNote
      @@ignored_assigns = %w( @template @_request @db_rt_before_render @db_rt_after_render @view_runtime )
      cattr_accessor :ignored_assigns, :instance_writter => false

      def initialize(controller)
        @controller = controller
      end

      def title
        "Assigns (#{assigns.size})"
      end

      def valid?
        assigns
      end

      def content
        rows = []
        assigns.each do |key|
          rows << [ key, assigned_value(key) ]
        end
        mount_table(rows.unshift(['Name', 'Value']), :class => 'name_values')
      end

      protected

        def assigns
          return @assigns if @assigns

          @assigns = @controller.instance_variables
          @assigns -= @controller.protected_instance_variables
          @assigns -= ignored_assigns
        end

        def assigned_value(key)
          escape(@controller.instance_variable_get(key).inspect)
        end
    end
  end
end
