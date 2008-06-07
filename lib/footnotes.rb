module Footnotes
  class Filter
    @@no_style = false
    @@multiple_notes = false
    # Edit notes
    @@notes = [ :controller, :view, :layout, :stylesheets, :javascripts ]
    # Show notes
    @@notes += [:session, :cookies, :params, :filters, :routes, :queries, :log, :general]

    cattr_accessor :no_style, :notes, :prefix, :multiple_notes

    def self.filter(controller)
      filter = Footnotes::Filter.new(controller)
      filter.add_footnotes!
      filter.reset!
    end

    def initialize(controller)
      @controller = controller
      @template = controller.instance_variable_get('@template')
      @body = controller.response.body
      initialize_notes!
    end

    def initialize_notes!
      @notes = []
      @@notes.flatten.each do |note|
        instance_note = eval("Footnotes::Notes::#{note.to_s.camelize}Note").new(@controller)
        @notes << instance_note if instance_note.valid?
      end
    end

    def reset!
      @notes.map(&:reset!)
    end

    def add_footnotes!
      if performed_render? && first_render?
        if valid_format? && valid_content_type? && @body.is_a?(String) && !xhr?
          insert_styles unless Footnotes::Filter.no_style
          insert_footnotes
        end
      end
    rescue Exception => e
      # Discard footnotes if there are any problems
      RAILS_DEFAULT_LOGGER.error "Footnotes Exception: #{e}\n#{e.backtrace.join("\n")}"
    end
    
    protected
    def performed_render?
      @controller.instance_variable_get('@performed_render')
    end

    def first_render?
      @template.first_render
    end

    def valid_format?
      [:html,:rhtml,:xhtml,:rxhtml].include?(@template.template_format.to_sym)
    end

    def valid_content_type?
      c = @controller.response.headers['Content-Type']
      (c.nil? || c =~ /html/)
    end

    def xhr?
      @controller.request.xhr?
    end

    #
    # Insertion methods
    #
    def insert_styles
      insert_text :before, /<\/head>/i, <<-HTML
      <!-- Footnotes Style -->
      <style type="text/css">
        #footnotes_debug {margin: 2em 0 1em 0; text-align: center; color: #444; line-height: 16px;}
        #footnotes_debug a {text-decoration: none; color: #444; line-height: 18px;}
        #footnotes_debug pre {overflow: scroll; margin: 0;}
        #footnotes_debug table {text-align: center;}
        #footnotes_debug table td {padding: 0 5px;}
        #footnotes_debug tbody {text-align: left;}
        #footnotes_debug legend {background-color: #FFF;}
        #footnotes_debug fieldset {text-align: left; border: 1px dashed #aaa; padding: 0.5em 1em 1em 1em; margin: 1em 2em; color: #444; background-color: #FFF;}
        /* Aditional Stylesheets */
        #{@notes.map(&:stylesheet).compact.join("\n")}
      </style>
      <!-- End Footnotes Style -->
      HTML
    end

    def insert_footnotes
      footnotes_html = <<-HTML
      <!-- Footnotes -->
      <div style="clear:both"></div>
      <div id="footnotes_debug">
        #{links}
        #{fieldsets}
        <script type="text/javascript">
          function footnotes_close(){
            #{close unless @@multiple_notes}
          }
          function footnotes_toogle(id){
            s = document.getElementById(id).style;
            before = s.display;
            footnotes_close();
            s.display = (before != 'block') ? 'block' : 'none'
            location.href = '#footnotes_debug';
          }
          /* Additional Javascript */
          #{@notes.map(&:javascript).compact.join("\n")}
        </script>
      </div>
      <!-- End Footnotes -->
      HTML
      if @body =~ %r{<div[^>]+id=['"]footnotes_holder['"][^>]*>}
        # Insert inside the "footnotes_holder" div if it exists
        insert_text :after, %r{<div[^>]+id=['"]footnotes_holder['"][^>]*>}, footnotes_html
      else
        # Otherwise, try to insert as the last part of the html body
        insert_text :before, /<\/body>/i, footnotes_html
      end
    end

    def links
      links = Hash.new([])
      order = []
      @notes.each do |note|
        order << note.row
        links[note.row] += [link_helper(note)]
      end

      html = ''
      order.uniq!
      order.each do |row|
        html << "#{row.to_s.capitalize}: #{links[row].join(" | \n")}<br />"
      end
      html
    end

    def fieldsets
      content = ''
      @notes.each do |note|
        next unless note.fieldset?
        content << <<-HTML
          <fieldset id="#{note.to_sym}_debug_info" style="display: none">
            <legend>#{note.legend}</legend>
            <code>#{note.content}</code>
          </fieldset>
        HTML
      end
      content
    end

    def close
      javascript = ''
      @notes.each do |note|
        next unless note.fieldset?
        javascript << close_helper(note)
      end
      javascript
    end

    # Helpers
    #
    def close_helper(note)
      "document.getElementById('#{note.to_sym}_debug_info').style.display = 'none'\n"
    end

    def link_helper(note)
      onclick = ''
      unless href = note.link
        href = '#'
        onclick = "footnotes_toogle('#{note.to_sym}_debug_info');return false;" if note.fieldset?
      end

      "<a href=\"#{href}\" onclick=\"#{onclick}\">#{note.title}</a>"
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
  end
end
