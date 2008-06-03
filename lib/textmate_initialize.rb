# The footnotes are applied by default to all actions. You can change this
# behavior commenting the after_filter line below and putting it in Your
# application. Then you can cherrypick in which actions it will appear.
#
# The support to render :footnotes => false was removed (usually you don't want
# to keep such only-development-code in the middle of your application).
#
class ActionController::Base
  after_filter Footnotes::Filter
end

module Footnotes
  module Routes
    # Filter routes according to the filter sent
    def filtered_routes(filter = {})
      return [] unless filter.is_a?(Hash)
      return routes.reject do |r| 
        filter_diff = filter.diff(r.requirements)
        route_diff  = r.requirements.diff(filter)
        (filter_diff == filter) || (filter_diff != route_diff)
      end
    end
  end
end

ActionController::Routing::RouteSet.send :include, Footnotes::Routes