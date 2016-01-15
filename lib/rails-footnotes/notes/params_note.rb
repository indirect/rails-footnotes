module Footnotes
  module Notes
    class ParamsNote < AbstractNote
      def initialize(controller)
        @params = if Rails::VERSION::MAJOR >= 5
          controller.params.to_unsafe_h
        else
          controller.params
        end
      end

      def title
        "Params (#{@params.length})"
      end

      def content
        mount_table_for_hash(@params, :summary => "Debug information for #{title}")
      end
    end
  end
end
