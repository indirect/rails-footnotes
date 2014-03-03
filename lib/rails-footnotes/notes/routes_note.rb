module Footnotes
  module Notes
    class RoutesNote < AbstractNote
      def initialize(controller)
        @controller = controller
        @parsed_routes = parse_routes
      end

      def legend
        "Routes for #{@controller.class.to_s}"
      end

      def content
        mount_table(@parsed_routes.unshift([:path, :name, :options, :requirements]), :summary => "Debug information for #{title}")
      end

      protected
        def parse_routes
          routes_with_name = Rails.application.routes.named_routes.to_a.flatten

          return Rails.application.routes.filtered_routes(:controller => @controller.controller_path).collect do |route|
            # Catch routes name if exists
            i = routes_with_name.index(route)
            name = i ? routes_with_name[i-1].to_s : ''

            # Catch segments requirements
            req = route.conditions
            [escape(name), route.conditions.keys.join, route.requirements.reject{|key,value| key == :controller}.inspect, req.inspect]
          end
        end
    end
  end

  module Extensions
    module Routes

      def __hash_diff(hash_self, other)
        # ActiveSupport::Deprecation.warn "Hash#diff is no longer used inside of Rails,
        # and is being deprecated with no replacement. If you're using it to compare hashes for the purpose of testing, please use MiniTest's diff instead."
        hash_self.dup.delete_if { |k, v| other[k] == v }.merge!(other.dup.delete_if { |k, v| hash_self.has_key?(k) })
      end

      # Filter routes according to the filter sent
      #
      def filtered_routes(filter = {})
        return [] unless filter.is_a?(Hash)
        return routes.reject do |r|
          filter_diff = __hash_diff(filter, r.requirements)
          route_diff  = __hash_diff(r.requirements, filter)

          (filter_diff == filter) || (filter_diff != route_diff)
        end
      end
    end
  end
end

if Footnotes::Notes::RoutesNote.included?
  ActionDispatch::Routing::RouteSet.send :include, Footnotes::Extensions::Routes
end
