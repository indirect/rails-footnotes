require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class ParamsNote < AbstractNote
      def initialize(controller)
        @params = controller.params.symbolize_keys
      end

      def title
        "Params (#{@params.length})"
      end

      def content
        escape(@params.inspect)
      end
    end
  end
end