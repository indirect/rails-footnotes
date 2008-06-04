require 'ostruct'

module Footnotes
  class Filter
    cattr_accessor :no_style, :notes, :sql

    self.no_style = false
    self.notes = [:session, :cookies, :params, :filters, :routes, :queries, :log, :general]
    self.sql = []

    #
    # Controller methods
    #
    def self.filter(controller)
      filter = Footnotes::Filter.new(controller)
      filter.add_footnotes!
      filter.reset!
    end

    def initialize(controller)
      @controller = controller
      @template = controller.instance_variable_get('@template')
      @body = controller.response.body
      @extra_html = ''
      @script = ''
    end

    def add_footnotes!
      if performed_render? && first_render?
        if [:html,:rhtml,:xhtml,:rxhtml].include?(@template.template_format.to_sym) && (content_type =~ /html/ || content_type.nil?) && !@controller.request.xhr?
          insert_styles unless Footnotes::Filter.no_style
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
    
    def reset!
      self.sql = []
    end

    #
    # Fieldset methods
    #
    def session_debug_info
      sessions = @controller.session.instance_variable_get("@data").symbolize_keys
      [escape(sessions.inspect), sessions.length]
    end

    def cookies_debug_info
      cookies = @controller.send(:cookies).symbolize_keys
      [escape(cookies.inspect), cookies.length]
    end

    def params_debug_info
      params = @controller.params.symbolize_keys
      [escape(params.inspect), params.length]
    end

    def filters_debug_info
      filters = parsed_filters.unshift([:name, :type, :actions])
      ["<pre>#{mount_table(filters)}</pre>", filters.length]
    end

    def routes_debug_info
      routes = parsed_routes.unshift([:path, :name, :options, :requirements])
      ["<pre>#{mount_table(routes)}</pre>", routes.length]
    end

    def queries_debug_info
      html = ''
      self.sql.collect do |item|
        html << "<b>#{item[0].to_s.upcase}</b>\n"
        html << "#{item[1] || 'SQL'} (#{sprintf('%f',item[2])}s)\n"
        html << "#{item[3].gsub(/(\s)+/,' ').gsub('`','')}\n"
        html << mount_table(item[4])
      end
      ["<pre>#{html}</pre>", self.sql.length]
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
    def mount_table(array)
      return '' if array.empty?
      header = '<tr><th>' + array.shift.collect{|i| escape(i.to_s.humanize) }.join('</th><th>') + '</th></tr>'
      lines = array.collect{|i| "<tr><td>#{i.join('</td><td>')}</td></tr>" }.join

      <<-TABLE
      <table>
        <thead>#{header}</thead>
        <tbody>#{lines}</tbody>
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
        #{textmate_links if Footnotes::Filter.textmate_prefix}
        Show:
        #{footnotes_content}
        #{@extra_html}
        <script type="text/javascript">function untoogle(){#{@script}}</script>
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

    # Generates footnotes script, links and content
    #
    def footnotes_content
      links = []
      content = ''

      self.notes.each{ |section|
        next unless footnotes_info.key?(section)

        # Call the method with the results
        result, total = eval("#{section.to_s}_debug_info")
        links << footnote_link(section, total)
        content << footnote_fieldset(section, result)
      }

      "#{links.join(" | \n")}#{content}"
    end

    # Defines the title and link names for each note
    #
    def footnotes_info
      return {
        :session => { :title => "Session", :link => "Session" },
        :cookies => { :title => "Cookies", :link => "Cookies (%d)" },
        :params => { :title => "Parameters", :link => "Params (%d)" },
        :filters => { :title => "Filter chain for #{@controller.class.to_s}", :link => "Filters" },
        :routes => { :title => "Routes for #{@controller.class.to_s}", :link => "Routes" },
        :queries => { :title => "Queries", :link => "Queries (%d)" },
        :log => { :title => "Log", :link => "Log" },
        :general => { :title => "General (id=\"tm_debug\")", :link => "General Debug" },
        :javascripts => { :title => "Javascripts", :link => "Javascripts (%d)" },
        :stylesheets => { :title => "Stylesheets", :link => "Stylesheets (%d)" }
      }
    end

    # Generate script that close notes when another is select
    #
    def footnote_script(section)
      @script << "document.getElementById('#{section.to_s}_debug_info').style.display = 'none'\n"
    end

    def footnote_link(section, value = 0)
      footnote_script(section)
      name = section.to_s
      "<a href=\"#\" onclick=\"untoogle();document.getElementById('#{name}_debug_info').style.display = 'block';location.href ='##{name}_debug_info';return false;\">#{(footnotes_info[section][:link] % value).humanize}</a>"
    end

    def footnote_fieldset(section, value)
      name = section.to_s
      <<-HTML
      <fieldset id="#{name}_debug_info" class="tm_footnotes_debug_info" style="display: none">
        <legend>#{footnotes_info[section][:title]}</legend>
        <code>#{value}</code>
      </fieldset>
      HTML
    end

    def insert_styles
      insert_text :before, /<\/head>/i, <<-HTML
      <!-- Footnotes Style -->
      <style type="text/css">
        #tm_footnotes_debug {margin: 2em 0 1em 0; text-align: center; color: #444; line-height: 16px;}
        #tm_footnotes_debug a {text-decoration: none; color: #444;}
        #tm_footnotes_debug pre {overflow: scroll; margin: 0;}
        #tm_footnotes_debug thead {text-align: center;}
        #tm_footnotes_debug table td {padding: 0 5px;}
        #tm_footnotes_debug tbody {text-align: left;}
        #tm_footnotes_debug legend, #tm_footnotes_debug fieldset {background-color: #FFF;}
        #queries_debug_info thead, #queries_debug_info tbody {text-align: center; color:#FF0000;}
        fieldset.tm_footnotes_debug_info {text-align: left; border: 1px dashed #aaa; padding: 0.5em 1em 1em 1em; margin: 1em 2em 1em 2em; color: #444;}
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
end