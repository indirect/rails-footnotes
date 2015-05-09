module Footnotes
  class Filter
    @@no_style = false
    @@multiple_notes = false
    @@klasses = []
    @@lock_top_right = false
    @@font_size = '11px'

    # Default link prefix is textmate
    @@prefix = 'txmt://open?url=file://%s&amp;line=%d&amp;column=%d'

    # Edit notes
    @@notes = [ :controller, :view, :layout, :partials, :stylesheets, :javascripts ]
    # Show notes
    @@notes += [ :assigns, :session, :cookies, :params, :filters, :routes, :env, :queries, :log]

    # :no_style       => If you don't want the style to be appended to your pages
    # :notes          => Class variable that holds the notes to be processed
    # :prefix         => Prefix appended to FootnotesLinks
    # :multiple_notes => Set to true if you want to open several notes at the same time
    # :lock_top_right => Lock a btn to toggle notes to the top right of the browser
    # :font_size      => CSS font-size property
    cattr_accessor :no_style, :notes, :prefix, :multiple_notes, :lock_top_right, :font_size

    class << self
      include Footnotes::EachWithRescue

      # Calls the class method start! in each note
      # Sometimes notes need to set variables or clean the environment to work properly
      # This method allows this kind of setup
      #
      def start!(controller)
        self.each_with_rescue(Footnotes.before_hooks) {|hook| hook.call(controller, self)}

        @@klasses = []
        self.each_with_rescue(@@notes.flatten) do |note|
          klass = "Footnotes::Notes::#{note.to_s.camelize}Note".constantize
          klass.start!(controller) if klass.respond_to?(:start!)
          @@klasses << klass
        end
      end

      # If none argument is sent, simply return the prefix.
      # Otherwise, replace the args in the prefix.
      #
      def prefix(*args)
        if args.empty?
          @@prefix
        else
          args.map! { |arg| URI.escape(arg.to_s) }

          if @@prefix.respond_to? :call
            @@prefix.call *args
          else
            format(@@prefix, *args)
          end
        end
      end

    end

    def initialize(controller)
      @controller = controller
      @template = controller.instance_variable_get(:@template)
      @notes = []

      revert_pos(controller.response_body) do
        @body = controller.response.body
      end
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
      self.each_with_rescue(@@klasses) {|klass| klass.close!(controller)}
      self.each_with_rescue(Footnotes.after_hooks) {|hook| hook.call(controller, self)}
    end

    protected
      def valid?
        @body.is_a?(String) && performed_render? && valid_format? && valid_content_type? &&
          !component_request? && !xhr? && !footnotes_disabled? && !attached_file?
      end

      def add_footnotes_without_validation!
        initialize_notes!
        insert_styles unless @@no_style
        insert_footnotes
      end

      def initialize_notes!
        each_with_rescue(@@klasses) do |klass|
          note = klass.new(@controller)
          @notes << note if note.valid?
        end
      end

      def revert_pos(file)
        return yield unless file.respond_to?(:pos) && file.respond_to?(:pos=)
        original = file.pos
        yield
        file.pos = original
      end

      def performed_render?
        @controller.respond_to?(:performed?) && @controller.performed?
      end

      def valid_format?
        ['text/html', nil].include? @controller.response.content_type
      end

      def valid_content_type?
        c = @controller.response.headers['Content-Type'].to_s
        (c.empty? || c =~ /html/)
      end

      def component_request?
        @controller.instance_variable_get(:@parent_controller)
      end

      def xhr?
        @controller.request.xhr?
      end

      def footnotes_disabled?
        @controller.params[:footnotes] == "false"
      end

      def attached_file?
        !!(@controller.headers['Content-Disposition'] =~ /attachment/)
      end

      #
      # Insertion methods
      #

      def insert_styles
        #TODO More customizable(reset.css, from file etc.)
        if @@lock_top_right
          extra_styles = <<-STYLES
            #footnotes_debug {position: fixed; top: 0px; right: 0px; width: 100%; z-index: 10000; margin-top: 0;}
            #footnotes_debug #toggle_footnotes {position: absolute; right: 0; top: 0; background: #fff; border: 1px solid #ccc; color: #9b1b1b; font-size: 20px; text-align: center; padding: 8px; opacity: 0.9;}
            #footnotes_debug #toggle_footnotes:hover {opacity: 1;}
            #footnotes_debug #all_footnotes {display: none; padding: 15px; background: #fff; box-shadow: 0 0 5px rgba(0,0,0,0.4);}
            #footnotes_debug fieldset > div {max-height: 500px; overflow: scroll;}
          STYLES
        else
          extra_styles = <<-STYLES
            #footnotes_debug #toggle_footnotes {display: none;}
          STYLES
        end
        insert_text :before, /<\/head>/i, <<-HTML
        <!-- Footnotes Style -->
        <style type="text/css">
          #footnotes_debug {font-size: #{@@font_size}; font-family: Consolas, monaco, monospace; font-weight: normal; margin: 2em 0 1em 0; text-align: center; color: #444; line-height: 16px; background: #fff;}
          #footnotes_debug th, #footnotes_debug td {color: #444; line-height: 18px;}
          #footnotes_debug a {color: #9b1b1b; font-weight: inherit; text-decoration: none; line-height: 18px;}
          #footnotes_debug table {text-align: left; width: 100%;}
          #footnotes_debug table td {padding: 5px; border-bottom: 1px solid #ccc;}
          #footnotes_debug table td strong {color: #9b1b1b;}
          #footnotes_debug table th {padding: 5px; border-bottom: 1px solid #ccc;}
          #footnotes_debug table tr:nth-child(2n) td {background: #eee;}
          #footnotes_debug table tr:nth-child(2n + 1) td {background: #fff;}
          #footnotes_debug tbody {text-align: left;}
          #footnotes_debug .name_values td {vertical-align: top;}
          #footnotes_debug legend {background-color: #fff;}
          #footnotes_debug fieldset {text-align: left; border: 1px dashed #aaa; padding: 0.5em 1em 1em 1em; margin: 1em 2em; color: #444; background-color: #FFF;}
          #{extra_styles}
          /* Aditional Stylesheets */
          #{@notes.map(&:stylesheet).compact.join("\n")}
        </style>
        <!-- End Footnotes Style -->
        HTML
      end

      def insert_footnotes
        # Fieldsets method should be called first
        content = fieldsets
        element_style = ''
        if @@lock_top_right
          element_style = 'style="display: none;"'
        end
        footnotes_html = <<-HTML
        <!-- Footnotes -->
        <div style="clear:both"></div>
        <div id="footnotes_debug">
          <a id="toggle_footnotes" href="#" onclick="Footnotes.toggle('all_footnotes'); return false;">fn</a>
          <div id="all_footnotes" #{element_style}>
            #{links}
            #{content}
          </div>
          <script type="text/javascript">
            var Footnotes = function() {

              function hideAll(){
                #{close unless @@multiple_notes}
              }

              function hideAllAndToggle(id) {
                var n = note(id);
                var display = n.style.display;
                hideAll();
                // Restore original display to allow toggling
                n.style.display = display;
                toggle(id)

                location.href = '#footnotes_debug';
              }

              function note(id) {
                return (document.getElementById(id));
              }

              function toggle(id){
                var el = note(id);
                if (el.style.display == 'none') {
                  Footnotes.show(el);
                } else {
                  Footnotes.hide(el);
                }
              }

              function show(element) {
                element.style.display = 'block'
              }

              function hide(element) {
                element.style.display = 'none'
              }

              return {
                show: show,
                hide: hide,
                toggle: toggle,
                hideAllAndToggle: hideAllAndToggle
              }
            }();
            /* Additional Javascript */
            #{@notes.map(&:javascript).compact.join("\n")}
          </script>
        </div>
        <!-- End Footnotes -->
        HTML

        placeholder = /<div[^>]+id=['"]footnotes_holder['"][^>]*>/i
        if @controller.response.body =~ placeholder
          insert_text :after, placeholder, footnotes_html
        else
          insert_text :before, /<\/body>/i, footnotes_html
        end
      end

      # Process notes to gets their links in their equivalent row
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

      # Process notes to get their content
      #
      def fieldsets
        content = ''
        each_with_rescue(@notes) do |note|
          next unless note.has_fieldset?
          content << <<-HTML
            <fieldset id="#{note.to_sym}_debug_info" style="display: none">
              <legend>#{note.legend}</legend>
              <div>#{note.content}</div>
            </fieldset>
          HTML
        end
        content
      end

      # Process notes to get javascript code to close them.
      # This method is only used when multiple_notes is false.
      #
      def close
        javascript = ''
        each_with_rescue(@notes) do |note|
          next unless note.has_fieldset?
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
        "Footnotes.hide(document.getElementById('#{note.to_sym}_debug_info'));\n"
      end

      # Helper that creates the link and javascript code when note is clicked
      #
      def link_helper(note)
        onclick = note.onclick
        unless href = note.link
          href = '#'
          onclick ||= "Footnotes.hideAllAndToggle('#{note.to_sym}_debug_info');return false;" if note.has_fieldset?
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
            if match = @controller.response.body.match(pattern)
              match.offset(0)[position == :before ? 0 : 1]
            else
              @controller.response.body.size
            end
          else
            pattern
          end
        newbody = @controller.response.body
        newbody.insert index, new_text
        @controller.response.body = newbody
      end

      # Instance each_with_rescue method
      #
      def each_with_rescue(*args, &block)
        self.class.each_with_rescue(*args, &block)
      end
  end
end
