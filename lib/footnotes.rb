module Footnotes
  class Filter
    @@no_style = false
    @@multiple_notes = false
    # Edit notes
    @@notes = [ :components, :controller, :view, :layout, :stylesheets, :javascripts ]
    # Show notes
    @@notes += [ :session, :cookies, :params, :filters, :routes, :queries, :log, :general ]

    # :no_style       => If you don't want the style to be appended to your pages
    # :notes          => Class variable that holds the ntoes to be processed
    # :prefix         => Prefix appended to FootnotesLinks
    # :multiple_notes => Set to true if you want to open several notes at the same time
    cattr_accessor :no_style, :notes, :prefix, :multiple_notes

    class << self
      # Method called to start the notes
      # It's a before filter prepend in the controller
      #
      def before(controller)
        Footnotes::Filter.start!(controller)
      end

      # Method that calls Footnotes to attach its contents
      #
      def after(controller)
        filter = Footnotes::Filter.new(controller)
        filter.add_footnotes!
        filter.close!(controller)
      end

      # Calls the class method start! in each note
      # Sometimes notes need to set variables or clean the environment to work properly
      # This method allows this kind of setup
      #
      def start!(controller)
        each_with_rescue(@@notes.flatten) do |note|
          klass = eval("Footnotes::Notes::#{note.to_s.camelize}Note") if note.is_a?(Symbol) || note.is_a?(String)
          klass.start!(controller) if klass.respond_to?(:start!)
        end
      end

      # Process notes, discarding only the note if any problem occurs
      #
      def each_with_rescue(notes)
        delete_me = []

        notes.each do |note|
          begin
            yield note
          rescue Exception => e
            # Discard note if it has a problem
            log_error("Footnotes #{note.to_s.camelize}Note Exception", e)
            delete_me << note
            next
          end
        end

        delete_me.each{ |note| notes.delete(note) }
      end

      # Logs the error using specified title and format
      #
      def log_error(title, exception)
        RAILS_DEFAULT_LOGGER.error "#{title}: #{exception}\n#{exception.backtrace.join("\n")}"
      end

    end

    def initialize(controller)
      @controller = controller
      @template = controller.instance_variable_get('@template')
      @body = controller.response.body
      @notes = []
    end

    def add_footnotes!
      add_footnotes_without_validation! if valid?
    rescue Exception => e
      # Discard footnotes if there are any problems
      self.class.log_error("Footnotes Exception", e)
    end

    # Calls the class method close! in each note
    # Sometimes notes need to finish their work even after being read
    # This method allows this kind of work
    #
    def close!(controller)
      each_with_rescue(@notes) do |note|
        note.class.close!(controller)
      end
    end

    protected
      def valid?
        performed_render? && first_render? && valid_format? && valid_content_type? && @body.is_a?(String) && !component_request? && !xhr?
      end

      def add_footnotes_without_validation!
        initialize_notes!
        insert_styles unless @@no_style
        insert_footnotes
      end

      def initialize_notes!
        each_with_rescue(@@notes.flatten) do |note|
          note = eval("Footnotes::Notes::#{note.to_s.camelize}Note").new(@controller) if note.is_a?(Symbol) || note.is_a?(String)
          @notes << note if note.respond_to?(:valid?) && note.valid?
        end
      end

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

      def component_request?
        @controller.instance_variable_get('@parent_controller')
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
        # Fieldsets method should be called first
        content = fieldsets

        footnotes_html = <<-HTML
        <!-- Footnotes -->
        <div style="clear:both"></div>
        <div id="footnotes_debug">
          #{links}
          #{content}
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

      # Process notes to gets its links
      #
      def links
        links = Hash.new([])
        order = []
        each_with_rescue(@notes) do |note|
          order << note.row
          links[note.row] += [link_helper(note)]
        end

        html = ''
        order.uniq!
        order.each do |row|
          html << "#{row.is_a?(String) ? row : row.to_s.camelize}: #{links[row].join(" | \n")}<br />"
        end
        html
      end

      # Process notes to get its contents
      #
      def fieldsets
        content = ''
        each_with_rescue(@notes) do |note|
          next unless note.fieldset?
          content << <<-HTML
            <fieldset id="#{note.to_sym}_debug_info" style="display: none">
              <legend>#{note.legend}</legend>
              <div>#{note.content}</div>
            </fieldset>
          HTML
        end
        content
      end

      # Process notes to get javascript code to close them all
      # This method is used with multiple_notes is false
      #
      def close
        javascript = ''
        each_with_rescue(@notes) do |note|
          next unless note.fieldset?
          javascript << close_helper(note)
        end
        javascript
      end

      #
      # Helpers
      #

      # Helper that creates the javascript code to close the note
      #
      def close_helper(note)
        "document.getElementById('#{note.to_sym}_debug_info').style.display = 'none'\n"
      end

      # Helper that create the link and javascript code when note is clicked
      #
      def link_helper(note)
        onclick = note.onclick
        unless href = note.link
          href = '#'
          onclick ||= "footnotes_toogle('#{note.to_sym}_debug_info');return false;" if note.fieldset?
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

      # Instance each_with_rescue method
      # 
      def each_with_rescue(*args, &block)
        self.class.each_with_rescue(*args, &block)
      end

  end
end
