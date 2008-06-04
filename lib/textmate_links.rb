module Footnotes
  module Links
    def self.included(base)
      base.class_eval do
        cattr_accessor :textmate_prefix    
      end
    end

    # Some controller classes come with the Controller:: module and some don't
    # (anyone know why? -- Duane)
    def controller_filename
      File.join(File.expand_path(RAILS_ROOT), 'app', 'controllers', "#{@controller.class.to_s.underscore}.rb").sub('/controllers/controllers/', '/controllers/')
    end

    def controller_text
      @controller_text ||= IO.read(controller_filename)
    end

    def index_of_method
      (controller_text =~ /def\s+#{@controller.action_name}[\s\(]/)
    end

    def controller_line_number
      lines_from_index(controller_text, index_of_method)
    end

    def template_path
      @template.first_render
    end

    def template_extension(path)
      @template.finder.pick_template_extension(path)
    end

    def template_base_path(path)
      @template.finder.pick_template(path, template_extension(path))
    end

    def template_file_name
      File.expand_path(template_base_path(template_path))
    end

    def layout_file_name
      File.expand_path(template_base_path(@controller.active_layout))
    end

    def stylesheet_files
      @stylesheet_files ||= @body.scan(/<link[^>]+href\s*=\s*['"]([^>?'"]+\.css)/im).flatten
    end

    def javascript_files
      @javascript_files ||= @body.scan(/<script[^>]+src\s*=\s*['"]([^>?'"]+\.js)/im).flatten
    end

    def controller_url
      escape(
        textmate_prefix +
        controller_filename +
        (index_of_method ? "&line=#{controller_line_number + 1}&column=3" : '')
      )
    end

    def view_url
      escape(textmate_prefix + template_file_name)
    end

    def layout_url
      escape(textmate_prefix + layout_file_name)
    end

    def textmate_links
      html = <<-HTML
        Edit:
        <a href="#{controller_url}">Controller</a> |
        <a href="#{view_url}">View</a> |
        <a href="#{layout_url}">Layout</a>
      HTML
      html += asset_file_links(:stylesheets, stylesheet_files) unless stylesheet_files.blank?
      html += asset_file_links(:javascripts, javascript_files) unless javascript_files.blank?
      html += '<br/>'
      return html
    end

    def asset_file_links(link_sym, files)
      return '' if files.size == 0
      links = files.map do |filename|
        if filename =~ %r{^/}
          full_filename = File.join(File.expand_path(RAILS_ROOT), 'public', filename)
          %{<a href="#{textmate_prefix}#{full_filename}">#{filename}</a>}
        else
          %{<a href="#{filename}">#{filename}</a>}
        end
      end
      @extra_html << footnote_fieldset(link_sym, "<ul><li>#{links.join("</li><li>")}</li></ul>")

      # Return the link that will open the 'extra html' div
      " | #{footnote_link(link_sym, links.length)}"
    end
    
    def lines_from_index(string, index)
      lines = string.to_a
      running_length = 0
      lines.each_with_index do |line, i|
        running_length += line.length
        if running_length > index
          return i
        end
      end
    end
  end
end

Footnotes::Filter.send :include, Footnotes::Links