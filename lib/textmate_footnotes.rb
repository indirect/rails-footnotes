require 'ostruct'

class FootnotesFilter
  cattr_accessor :no_style, :notes
  self.no_style = false
  self.notes = [:session, :cookies, :params, :filters, :routes, :log, :general]

  #
  # Controller methods
  #
  def self.filter(controller)
    filter = FootnotesFilter.new(controller)
    filter.add_footnotes!   
  end

  def initialize(controller)
    @controller = controller
    @template = controller.instance_variable_get('@template')
    @body = controller.response.body
    @extra_html = ''
  end

  def add_footnotes!
    if performed_render? && first_render?
      if [:html,:rhtml,:xhtml,:rxhtml].include?(@template.template_format.to_sym) && (content_type =~ /html/ || content_type.nil?) && !@controller.request.xhr?
        insert_styles unless FootnotesFilter.no_style
        insert_footnotes
      end
    end
  rescue Exception => e
    # Discard footnotes if there are any problems
    RAILS_DEFAULT_LOGGER.error "Footnotes Exception: #{e}\n#{e.backtrace.join("\n")}"
  end

  def performed_render?
    @controller.instance_variable_get('@performed_render')
  end

  def first_render?
    @template.first_render
  end

  def content_type
    @controller.response.headers['Content-Type']
  end

  #
  # Fieldset methods
  #
  def session_debug_info
    escape(@controller.session.instance_variable_get("@data").inspect)
  end

  def cookies_debug_info
    escape(@controller.send(:cookies).inspect)
  end

  def params_debug_info
    escape(@controller.params.inspect)
  end

  def filters_debug_info
    "<pre>#{mount_table(parsed_filters, :name, :type, :actions)}</pre>"
  end

  def routes_debug_info
    "<pre>#{mount_table(parsed_routes, :path, :name, :options, :requirements)}</pre>"
  end

  def log_debug_info
    "<pre>#{escape(log_tail)}</pre>"
  end

  def general_debug_info
    'You can use this tab to debug other parts of your application, for example Javascript.'
  end

  #
  # Helpers used to mount the fieldsets
  #
  def log_tail
    file_string = File.open(RAILS_DEFAULT_LOGGER.instance_variable_get('@log').path).read.to_s

    # We try to select the specified action from the log
    # If we can't find it, we get the last 100 lines
    #
    if rindex = file_string.rindex('Processing '+@controller.controller_class_name+'#'+@controller.action_name)
      file_string[rindex..-1].gsub(/\e\[.+?m/, '')
    else
      lines = file_string.split("\n")
      index = [lines.size-100,0].max
      lines[index..-1].join("\n")
    end
  end

  # Gets a bidimensional array with the labels of the "second" array (columns)
  #
  def mount_table(array, *args)
    return '' if args.empty?
    header = '<tr><th>' + args.collect{|i| escape(i.to_s.titlecase) }.join('</th><th>') + '</th></tr>'
    lines = array.collect{|i| "<tr><td>#{i.join('</td><td>')}</td></tr>" }.join

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

      [escape(name), route.segments.join, route.requirements.reject{|key,value| key == :controller}.inspect, req.inspect]
    end
  end

  def parsed_filters
    return @controller.class.filter_chain.collect do |filter|
      [filter.method.inspect, filter.type.inspect, controller_filtered_actions(filter).inspect]
    end
  end

  # This methods creates a mock controller, gives it an action name and check if
  # the action should run in filter.
  #
  def controller_filtered_actions(filter)
    mock_controller = OpenStruct.new
    return @controller.class.action_methods.select { |action|
      mock_controller.action_name = action
      filter.options.merge!(:if => nil, :unless => nil) #remove conditions (this would call a Proc on the mock_controller)
      filter.send!(:should_run_callback?, mock_controller)   
    }.map(&:to_sym)
  end

  #
  # Insertion methods
  #
  def insert_footnotes   
    footnotes_html = <<-HTML
    <!-- Footnotes -->
    <div style="clear:both"></div>
    <div id="tm_footnotes_debug">
      #{textmate_links if FootnotesFilter.textmate_prefix}
      Show:
      #{footnotes_links}
      #{@extra_html}
      #{footnotes_fieldsets}
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

  # Defines the title for each fieldset
  #
  def footnotes_titles
    return {
      :session => "Session",
      :cookies => "Cookies",
      :params => "Parameters",
      :filters => "Filter chain for #{@controller.class.to_s}",
      :routes => "Routes for #{@controller.class.to_s}",
      :log => "Log",
      :general => "General (id=\"tm_debug\")"
    }
  end

  # Generates links based on specified tabs
  #
  def footnotes_links
    def tm_footnotes_toggle(id)
      "s = document.getElementById('#{id}').style; if(s.display == 'none') { s.display = '' } else { s.display = 'none' }"
    end

    self.notes.collect{ |section|
      next unless footnotes_titles.key?(section)
      section_name = section.to_s
      "<a href=\"#\" onclick=\"#{tm_footnotes_toggle(section_name+'_debug_info')};return false\">#{section_name.titleize}</a>"
    }.join(" | \n")
  end

  # Generates fieldsets based on specified tabs
  #
  def footnotes_fieldsets
    self.notes.collect{ |section|
      next unless footnotes_titles.key?(section)
      section_name = section.to_s
      <<-HTML
      <fieldset id="#{section_name}_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>#{footnotes_titles[section]}</legend>
        <code>#{eval(section_name+'_debug_info')}</code>
      </fieldset>
      HTML
    }
  end

  def insert_styles
    insert_text :before, /<\/head>/i, <<-HTML
    <!-- Footnotes Style -->
    <style type="text/css">
      #tm_footnotes_debug {margin: 2em 0 1em 0; text-align: center; color: #777;}
      #tm_footnotes_debug a {text-decoration: none; color: #777;}
      #tm_footnotes_debug pre {overflow: scroll; margin: 0;}
      #tm_footnotes_debug table td {padding: 0 4px;}
      #tm_footnotes_debug legend, #tm_footnotes_debug fieldset {background-color: #FFF;}
      fieldset.tm_footnotes_debug_info {text-align: left; border: 1px dashed #aaa; padding: 0.5em 1em 1em 1em; margin: 1em 2em 1em 2em; color: #777;}
    </style>
    <!-- End Footnotes Style -->
    HTML
  end

  # Inserts text in to the body of the document
  # +pattern+ is a Regular expression which, when matched, will cause +new_text+
  # to be inserted before or after the match.  If no match is found, +new_text+ is appended
  # to the body instead. +position+ may be either :before or :after
  #
  def insert_text(position, pattern, new_text)
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
    @body.insert index, new_text
  end

  def escape(text)
    text.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
  end
end