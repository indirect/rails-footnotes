require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class VariablesNote < AbstractNote
      def initialize(controller)
        @controller = controller
      end

      def legend
        "Variables for #{@controller.class.to_s}"
      end

      def content
        result = [['Name', 'Value']]
        variable_detail = @controller.params[:variable_detail] || []
        @controller.instance_variables.each {|v| result << [v, variable_detail.index('ALL') || variable_detail.include?(v) ?  escape(@controller.instance_variable_get(v).inspect) : @controller.instance_variable_get(v)]}
        
        mount_table(result, :id => "footnotes_variables")
      end
    end
  end
end
