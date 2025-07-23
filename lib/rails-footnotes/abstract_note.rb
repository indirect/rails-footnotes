module Footnotes
  module Notes
    # This is the abstract class for notes.
    # You can overwrite all instance public methods to create your notes.
    #
    class AbstractNote

      # Class methods. Do NOT overwrite them.
      #
      class << self
        # Returns the symbol that represents this note.
        # It's the name of the class, underscored and without _note.
        #
        # For example, for ControllerNote it will return :controller.
        #
        def to_sym
          @note_sym ||= self.title.underscore.to_sym
        end

        # Returns the title that represents this note.
        # It's the name of the class without Note.
        #
        # For example, for ControllerNote it will return Controller.
        #
        def title
          @note_title ||= self.name.match(/^Footnotes::Notes::(\w+)Note$/)[1]
        end

        # Return true if Note is included in notes array.
        #
        def included?
          Footnotes::Filter.notes.include?(self.to_sym)
        end

        # Action to be called to start the Note.
        # This is applied as a before_filter.
        #
        def start!(controller = nil)
        end

        # Action to be called after the Note was used.
        # This is applied as an after_filter.
        #
        def close!(controller = nil)
        end
      end

      # Initialize notes.
      # Always receives a controller.
      #
      def initialize(controller = nil)
      end

      # Returns the symbol that represents this note.
      #
      def to_sym
        self.class.to_sym
      end

      # Specifies in which row should appear the title.
      # The default is :show.
      #
      def row
        :show
      end

      # Returns the title to be used as link.
      # The default is the note title.
      #
      def title
        self.class.title
      end

      # If has_fieldset? is true, create a fieldset with the value returned as legend.
      # By default, returns the title of the class (defined above).
      #
      def legend
        self.class.title
      end

      # If content is defined, has_fieldset? returns true and the value of content
      # is displayed when the Note is clicked. See has_fieldset? below for more info.
      #
      # def content
      # end

      # Set href field for Footnotes links.
      # If it's nil, Footnotes will use '#'.
      #
      def link
      end

      # Set onclick field for Footnotes links.
      # If it's nil, Footnotes will make it open the fieldset.
      #
      def onclick
      end

      # Insert here any additional stylesheet.
      # This is directly inserted into a <style> tag.
      #
      def stylesheet
      end

      # Insert here any additional javascript.
      # This is directly inserted into a <script> tag.
      #
      def javascript
      end

      # Specifies when should create a note for it.
      # By default, it's valid.
      #
      def valid?
        true
      end

      # Specifies when should create a fieldset for it, considering it's valid.
      #
      def has_fieldset?
        self.respond_to?(:content)
      end

      # Some helpers to generate notes.
      #
      public
        # Return if Footnotes::Filter.prefix exists or not.
        # Some notes only work with prefix set.
        #
        def prefix?
          !Footnotes::Filter.prefix.blank?
        end

        # Escape HTML special characters.
        #
        def escape(text)
          text.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        end

        # Gets a bidimensional array and create a table.
        # The first array is used as label.
        #
        def mount_table(array, options = {})
          header = array.shift
          return '' if array.empty?

          header = header.collect{|i| escape(i.to_s.humanize) }
          rows = array.collect{|i| "<tr><td>#{i.join('</td><td>')}</td></tr>" }

          <<-TABLE
          <table #{hash_to_xml_attributes(options)}>
            <thead><tr><th>#{header.join('</th><th>')}</th></tr></thead>
            <tbody>#{rows.join}</tbody>
          </table>
          TABLE
        end

        # Mount table for hash, using name and value and adding a name_value class
        # to the generated table.
        #
        def mount_table_for_hash(hash, options={})
          rows = []
          hash.each do |key, value|
            rows << [ key.to_sym.inspect, escape(value.inspect) ]
          end
          mount_table(rows.unshift(['Name', 'Value']), {:class => 'name_value'}.merge(options))
        end

        def hash_to_xml_attributes(hash)
          newstring = ""
          hash.each do |key, value|
            newstring += "#{key.to_s}=\"#{value.gsub('"','\"')}\" "
          end
          return newstring
        end
    end
  end
end
