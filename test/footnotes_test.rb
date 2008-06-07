require 'test/unit'
require 'rubygems'
require 'mocha'

ENV["RAILS_ENV"] = "test"

require 'active_support'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'

require File.dirname(__FILE__) + '/../lib/footnotes'
require File.dirname(__FILE__) + '/../lib/notes/abstract_note'

class FootnotesController < ActionController::Base; attr_accessor :template, :performed_render; end

class FootnotesTest < Test::Unit::TestCase
  def setup
    @controller = FootnotesController.new
    @controller.request = ActionController::TestRequest.new
    @controller.response = ActionController::TestResponse.new
    @controller.response.body = $html.dup

    Footnotes::Filter.notes = [:abstract]
    Footnotes::Filter.multiple_notes = false
    @footnotes = Footnotes::Filter.new(@controller)
  end

  def test_footnotes_controller
    index = @controller.response.body.index(/This is the HTML page/)
    assert_equal 334, index
  end
  
  def test_foonotes_included
    footnotes_perform!
    assert_not_equal $html, @controller.response.body
  end

  def test_footnotes_not_included_when_request_is_xhr
    @controller.request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    @controller.request.env['HTTP_ACCEPT'] = 'text/javascript, text/html, application/xml, text/xml, */*'

    footnotes_perform!
    assert_equal $html, @controller.response.body
  end

  def test_footnotes_not_included_when_content_type_is_javascript
    @controller.response.headers['Content-Type'] = 'text/javascript'

    footnotes_perform!
    assert_equal $html, @controller.response.body
  end

  def test_footnotes_included_when_content_type_is_html
    @controller.response.headers['Content-Type'] = 'text/html'

    footnotes_perform!
    assert_not_equal $html, @controller.response.body
  end

  def test_footnotes_included_when_content_type_is_nil
    footnotes_perform!
    assert_not_equal $html, @controller.response.body
  end

  def test_not_included_when_body_is_not_a_string
    @controller.response.body = Proc.new{ Time.now }
    @footnotes = Footnotes::Filter.new(@controller)
    footnotes_perform!
  end

  def test_notes_are_initialized
    footnotes_perform!
    abstract_note = @footnotes.instance_variable_get('@notes').first
    assert 'Footnotes::Notes::AbstractNote', abstract_note.class
    assert :abstract, abstract_note.to_sym
  end

  def test_notes_links
    footnotes_perform!
    @footnotes.instance_variable_get('@notes').first.expects(:valid?).times(3)
    footnotes_perform!
  end

  def test_notes_fieldset
    footnotes_perform!
    @footnotes.instance_variable_get('@notes').first.expects(:fieldset?).times(2)
    footnotes_perform!
  end

  def test_multiple_notes
    Footnotes::Filter.multiple_notes = true
    footnotes_perform!
    @footnotes.instance_variable_get('@notes').first.expects(:valid?).times(2)
    footnotes_perform!
  end

  def test_notes_are_reset
    footnotes_perform!
    @footnotes.instance_variable_get('@notes').first.expects(:reset!)
    @footnotes.send(:reset!)
  end

  def test_links_helper
    assert_equal '<a href="#" onclick="footnotes_toogle(\'abstract_debug_info\');return false;">content</a>', @footnotes.send(:link_helper, :abstract, :content, nil)
    assert_equal '<a href="link" onclick="">content</a>', @footnotes.send(:link_helper, :abstract, :content, :link)
  end

  def test_insert_style
    @controller.response.body = "<head></head><split><body></body>"
    @footnotes = Footnotes::Filter.new(@controller)
    footnotes_perform!
    assert @controller.response.body.split('<split>').first.include?('<!-- Footnotes Style -->')
  end

  def test_insert_footnotes_inside_body
    @controller.response.body = "<head></head><split><body></body>"
    @footnotes = Footnotes::Filter.new(@controller)
    footnotes_perform!
    assert @controller.response.body.split('<split>').last.include?('<!-- End Footnotes -->')
  end

  def test_insert_footnotes_inside_holder
    @controller.response.body = "<head></head><split><div id='footnotes_holder'></div>"
    @footnotes = Footnotes::Filter.new(@controller)
    footnotes_perform!
    assert @controller.response.body.split('<split>').last.include?('<!-- End Footnotes -->')
  end

  def test_insert_text
    @footnotes.send(:insert_text, :after, /<head>/, "Graffiti")
    after = "    <head>Graffiti\n"
    assert_equal after, @controller.response.body.to_a[2]

    @footnotes.send(:insert_text, :before, /<\/body>/, "Notes")
    after = "    Notes</body>\n"
    assert_equal after, @controller.response.body.to_a[12]
  end
  
  protected
    # First we make sure that footnotes will perform (long life to mocha!)
    # Then we call add_footnotes!
    #
    def footnotes_perform!
      @controller.template.expects(:first_render).returns(true)
      @controller.performed_render = true
      @controller.template.expects(:template_format).returns('html')

      @footnotes.add_footnotes!
    end
end

$html = <<HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <head>
        <title>HTML to XHTML Example: HTML page</title>
        <link rel="Stylesheet" href="htmltohxhtml.css" type="text/css" media="screen">
        <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
    </head>
    <body>
        <p>This is the HTML page. It works and is encoded just like any HTML page you
         have previously done. View <a href="htmltoxhtml2.htm">the XHTML version</a> of
         this page to view the difference between HTML and XHTML.</p>
        <p>You will be glad to know that no changes need to be made to any of your CSS files.</p>
    </body>
</html>
HTML