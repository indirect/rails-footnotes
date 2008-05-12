class FootnotesFilter
  cattr_accessor :no_style
  self.no_style = false

  def self.filter(controller)
    filter = FootnotesFilter.new(controller)
    filter.add_footnotes!
  end

  def initialize(controller)
    @controller = controller
    @template = controller.instance_variable_get("@template")
    @body = controller.response.body
    @extra_html = ""
  end

  def add_footnotes!
    if performed_render? and first_render?
      if ['html','rhtml','xhtml','rxhtml'].include?(template_format.to_s) && (content_type =~ /html/ || content_type.nil?) && !@controller.request.xhr?
        insert_styles unless FootnotesFilter.no_style
        insert_footnotes
      end
    end
  rescue Exception => e
    # Discard footnotes if there are any problems
    RAILS_DEFAULT_LOGGER.error "Footnotes Exception: #{e}\n#{e.backtrace.join("\n")}"
  end

  def performed_render?
    @controller.instance_variable_get("@performed_render")
  end

  def first_render?
    @template.respond_to?(:first_render) and @template.first_render
  end

  def content_type
    @controller.response.headers['Content-Type']
  end

  def template_path
    @template.first_render
  end

  def template_extension
    @template.pick_template_extension(template_path)
  end

  def template_format
    @template.respond_to?(:template_format) ? @template.template_format : template_extension # condition for Rails < 2.0 compatibiliy
  end

  def insert_styles
    insert_text :before, /<\/head>/i, <<-HTML
    <!-- Footnotes Style -->
    <style type="text/css">
      #tm_footnotes_debug {margin: 2em 0 1em 0; text-align: center; color: #777;}
      #tm_footnotes_debug a {text-decoration: none; color: #777;}
      #tm_footnotes_debug pre {overflow: scroll;}
      fieldset.tm_footnotes_debug_info {text-align: left; border: 1px dashed #aaa; padding: 0.5em 1em 1em 1em; margin: 1em 2em 1em 2em; color: #777;}
    </style>
    <!-- End Footnotes Style -->
    HTML
  end

  def insert_footnotes
    def tm_footnotes_toggle(id)
      "s = document.getElementById('#{id}').style; if(s.display == 'none') { s.display = '' } else { s.display = 'none' }"
    end

    footnotes_html = <<-HTML
    <!-- Footnotes -->
    <div style="clear:both"></div>
    <div id="tm_footnotes_debug">
      #{textmate_links if FootnotesFilter.textmate_prefix}
      Show:
      <a href="#" onclick="#{tm_footnotes_toggle('session_debug_info')};return false">Session</a> |
      <a href="#" onclick="#{tm_footnotes_toggle('cookies_debug_info')};return false">Cookies</a> |
      <a href="#" onclick="#{tm_footnotes_toggle('params_debug_info')};return false">Params</a> |
      <a href="#" onclick="#{tm_footnotes_toggle('log_debug_info')};return false">Log</a> |
      <a href="#" onclick="#{tm_footnotes_toggle('filters_debug_info')};return false">Filters</a> |
      <a href="#" onclick="#{tm_footnotes_toggle('routes_debug_info')};return false">Routes</a> |
      <a href="#" onclick="#{tm_footnotes_toggle('general_debug_info')};return false">General Debug</a>
      #{@extra_html}
      <fieldset id="session_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>Session</legend>
        #{escape(@controller.session.instance_variable_get("@data").inspect)}
      </fieldset>
      <fieldset id="cookies_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>Cookies</legend>
        <code>#{escape(@controller.send(:cookies).inspect)}</code>
      </fieldset>
      <fieldset id="params_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>Params</legend>
        <code>#{escape(@controller.params.inspect)}</code>
      </fieldset>
      <fieldset id="log_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>Log</legend>
        <code><pre>#{escape(log_tail)}</pre></code>
      </fieldset>
      <fieldset id="filters_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>Filter chain for Controller #{@controller.controller_name}</legend>
        <code><pre>#{mount_table(parsed_filters, :name, :type, :included_actions, :excluded_actions)}</pre></code>
      </fieldset>
      <fieldset id="routes_debug_info" class="tm_footnotes_debug_info" style="display:none;text-align:center;">
        <legend>Routes for Controller #{@controller.controller_name}</legend>
        <code><pre>#{mount_table(parsed_routes, :path, :name, :options, :requirements)}</pre></code>
      </fieldset>
      <fieldset id="general_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>General (id="tm_debug")</legend>
        <div id="tm_debug">You can use this tab to debug other parts of your application, for example Javascript.</div>
      </fieldset>
    </div>
    <!-- End Footnotes -->
    HTML
    if @body =~ %r{<div[^>]+id=['"]tm_footnotes['"][^>]*>}
      # Insert inside the "tm_footnotes" div if it exists
      insert_text :after, %r{<div[^>]+id=['"]tm_footnotes['"][^>]*>}, footnotes_html
    else
      # Otherwise, try to insert as the last part of the html body
      insert_text :before, /<\/body>/i, footnotes_html
    end
  end

  def log_tail
    filename = RAILS_DEFAULT_LOGGER.instance_variable_get('@log') ? RAILS_DEFAULT_LOGGER.instance_variable_get('@log').path : RAILS_DEFAULT_LOGGER.instance_variable_get('@logdev').filename # condition for Rails < 2.0 compatibility 
    file_string = File.open(filename).read.to_s
    html = file_string[file_string.rindex('Processing '+@controller.controller_class_name+'#'+@controller.action_name),file_string.size].gsub(/\e\[.+?m/, '')
  end

  # Gets a bidimensional array with the labels of the "second" array data
  def mount_table(*args)
    return '' if args.empty?
    array = args.delete_at(0)
    header = '<tr><th>'+args.collect{|i| i.to_s.titlecase }.join('</th><th>')+'</th></tr>'
    lines = array.collect{|i| '<tr><td>'+i.join('</td><td>')+'</td></tr>' }.join
    
    <<-TABLE
    <table>
      <thead>#{header}</thead>
      <tbody style="text-align:left;">
        #{lines}
      </tbody>
    </table>
    TABLE
  end

  def parsed_routes
    routes_with_name = ActionController::Routing::Routes.named_routes.to_a.flatten
    return ActionController::Routing::Routes.filtered_routes(:controller => @controller.controller_name).collect do |route|
      # Catch routes name if exists
      i = routes_with_name.index(route)
      name = i ? routes_with_name[i-1].to_s : ''

      # Catch segments requirements
      req = {}
      route.segments.each do |segment|
        next unless segment.is_a?(ActionController::Routing::DynamicSegment) && segment.regexp
        req[segment.key.to_sym] = segment.regexp
      end

      [name,route.segments.join,route.requirements.reject{|key,value| key == :controller}.inspect,req.inspect]
    end
  end

  def parsed_filters
    controller_class = @controller.class

    return controller_class.filter_chain.collect do |filter|
      if excluded_actions = controller_class.excluded_actions[filter]
        included_actions = []
      else
        included_actions = controller_class.included_actions[filter] || controller_class.action_methods
        excluded_actions = []
      end

                              # condition for Rails < 2.0 compatibility
      [filter.filter.inspect, (filter.respond_to?(:type) ? filter.type : filter.class).inspect, included_actions.map(&:to_sym).inspect, excluded_actions.map(&:to_sym).inspect]
    end
  end

  def indent(indentation, text)
    lines = text.to_a
    initial_indentation = lines.first.scan(/^(\s+)/).flatten.first
    lines.map do |line|
      if initial_indentation.nil?
        " " * indentation + line
      elsif line.index(initial_indentation) == 0
        " " * indentation + line[initial_indentation.size..-1]
      else
        " " * indentation + line
      end
    end.join
  end

  # Inserts text in to the body of the document
  # +pattern+ is a Regular expression which, when matched, will cause +new_text+
  # to be inserted before or after the match.  If no match is found, +new_text+ is appended
  # to the body instead. +position+ may be either :before or :after
  def insert_text(position, pattern, new_text, indentation = 4)
    index = case pattern
      when Regexp
        if match = @body.match(pattern)
          match.offset(0)[position == :before ? 0 : 1]
        else
          @body.size
        end
      else
        pattern
      end
    @body.insert index, indent(indentation, new_text)
  end

  def escape(text)
    text.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
  end
end