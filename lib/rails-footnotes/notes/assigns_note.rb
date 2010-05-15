require "#{File.dirname(__FILE__)}/abstract_note"

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
        assigns
      end

      def content
        rows = []
        assigns.each do |key|
          rows << [ key, escape(assigned_value(key)) ]
        end
        mount_table(rows.unshift(['Name', 'Value']), :class => 'name_values', :summary => "Debug information for #{title}")
      end

      protected

        def assigns
          assign = []
          ignored = @@ignored_assigns
          
          @controller.instance_variables.each {|x| assign << x.intern }
          @controller.protected_instance_variables.each {|x| ignored << x.intern } if @controller.respond_to? :protected_instance_variables
           
          assign -= ignored            
          return assign
        end

        def assigned_value(key)
          @controller.instance_variable_get(key).inspect
        end
    end
  end
end
