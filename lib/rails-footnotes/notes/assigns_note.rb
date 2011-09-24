module Footnotes
  module Notes
    class AssignsNote < AbstractNote
      @@ignored_assigns = [
                            :@real_format,
                            :@before_filter_chain_aborted,
                            :@performed_redirect,
                            :@performed_render,
                            :@_params,
                            :@_response,
                            :@url,
                            :@template,
                            :@_request,
                            :@db_rt_before_render,
                            :@db_rt_after_render,
                            :@view_runtime
                          ]
      cattr_accessor :ignored_assigns, :instance_writter => false

      def initialize(controller)
        @controller = controller
      end

      def title
        "Assigns (#{assigns.size})"
      end

      def valid?
        assigns.present?
      end

      def content
        mount_table(to_table, :summary => "Debug information for #{title}")
      end

      protected
        def to_table
          @to_table ||= assigns.inject([]) {|rr, var| rr << [var, escape(assigned_value(var))]}.unshift(['Name', 'Value'])
        end

        def assigns
          @assigns ||= @controller.instance_variables.map {|v| v.to_sym} - ignored_assigns
        end

        def assigned_value(key)
          @controller.instance_variable_get(key).inspect
        end
    end
  end
end
