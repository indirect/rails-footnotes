require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class RpmNote < AbstractNote
      def initialize(controller)
        @rpm_id=NewRelic::Agent.instance.transaction_sampler.current_sample_id
      end

      def row
        :edit
      end

      def link
         #{:controller => 'newrelic', :action => 'show_sample_detail', :id => @rpm_id}
         "/newrelic/show_sample_detail/#{@rpm_id}"
      end
      
      def valid?
        !NewRelic::Config.instance['skip_developer_route']
      end
    end
  end
end
