# The footnotes are applied by default to all actions. You can change this
# behavior commenting the after_filter line below and putting it in Your
# application. Then You can cherrypick in which actions it will appear.
#
# The support to render :footnotes => false was removed (usually You don't want
# to keep such only-development-code in the middle of Your application).
#
class ActionController::Base
  after_filter FootnotesFilter
end

# Add routes config
class ActionController::Routing::RouteSet
  def filtered_routes(filter = {})
    return [] unless filter.is_a?(Hash)
    return routes.reject do |r| 
      filter_diff = filter.diff(r.requirements)
      route_diff  = r.requirements.diff(filter)
      (filter_diff == filter) || (filter_diff != route_diff)
    end
  end
end
