class String
  def line_from_index(index)
    lines = self.to_a
    running_length = 0
    lines.each_with_index do |line, i|
      running_length += line.length
      if running_length > index
        return i
      end
    end
  end
end

class FootnotesFilter
  cattr_accessor :textmate_prefix

  # Some controller classes come with the Controller:: module and some don't
  # (anyone know why? -- Duane)
  def controller_filename
    File.join(File.expand_path(RAILS_ROOT), 'app', 'controllers', "#{@controller.class.to_s.underscore}.rb").
    sub('/controllers/controllers/', '/controllers/')
  end

  def controller_text
    @controller_text ||= IO.read(controller_filename)
  end

  def index_of_method
    (controller_text =~ /def\s+#{@controller.action_name}[\s\(]/)
  end
  
  def controller_line_number
    controller_text.line_from_index(index_of_method)
  end
  
  def template_file_name
    File.expand_path(@template.send(:full_template_path, template_path, template_extension))
  end

  def layout_file_name
    File.expand_path(@template.send(:full_template_path, @controller.active_layout, @template.pick_template_extension(@controller.active_layout)))
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
    html += asset_file_links('Stylesheets', stylesheet_files) unless stylesheet_files.blank?
    html += asset_file_links('Javascripts', javascript_files) unless javascript_files.blank?
    html += '<br/>'
    return html
  end

  def asset_file_links(link_text, files)
    return '' if files.size == 0
    links = files.map do |filename|
      if filename =~ %r{^/}
        full_filename = File.join(File.expand_path(RAILS_ROOT), 'public', filename)
        %{<a href="#{textmate_prefix}#{full_filename}">#{filename}</a>}
      else
        %{<a href="#{filename}">#{filename}</a>}
      end
    end
    @extra_html << <<-HTML
      <fieldset id="tm_footnotes_#{link_text.underscore.gsub(' ', '_')}" class="tm_footnotes_debug_info" style="display: none">
        <legend>#{link_text}</legend>
        <ul><li>#{links.join("</li><li>")}</li></ul>
      </fieldset>
    HTML
    # Return the link that will open the 'extra html' div
    %{ | <a href="#" onclick="#{tm_footnotes_toggle('tm_footnotes_' + link_text.underscore.gsub(' ', '_') )}; return false">#{link_text}</a>}
  end
end