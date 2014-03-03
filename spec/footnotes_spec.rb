require "spec_helper"
require 'action_controller'
require 'action_controller/test_case'
require "tempfile"

class FootnotesController < ActionController::Base
  attr_accessor :template, :performed_render
end

module Footnotes::Notes
  class TestNote < AbstractNote
    def self.to_sym; :test; end
    def valid?; true; end
  end

  class NoteXNote < TestNote; end
  class NoteYNote < TestNote; end
  class NoteZNote < TestNote; end
end

describe "Footnotes" do
  before do
    @controller = FootnotesController.new
    @controller.template = Object.new
    @controller.request = ActionController::TestRequest.new
    @controller.response = ActionController::TestResponse.new
    @controller.response_body = HTML_DOCUMENT.dup
    @controller.params = {}

    Footnotes::Filter.notes = [ :test ]
    Footnotes::Filter.multiple_notes = false
    @footnotes = Footnotes::Filter.new(@controller)
  end

  it "footnotes_controller" do
    index = @controller.response.body.index(/This is the HTML page/)
    index.should eql 334
  end

  context "response_body is file" do
    before do
      @file = Tempfile.new("test")
      @file.write "foobarbaz"
      @file.rewind
    end

    after do
      @file.close!
    end

    it "should not change file position" do
      @controller.response_body = @file
      expect {
        @footnotes = Footnotes::Filter.new(@controller)
      }.not_to change{ @controller.response_body.pos }
    end
  end

  it "foonotes_included" do
    footnotes_perform!
    @controller.response_body.should_not == HTML_DOCUMENT
  end

  specify "footnotes_not_included_when_request_is_xhr" do
    @controller.request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    @controller.request.env['HTTP_ACCEPT'] = 'text/javascript, text/html, application/xml, text/xml, */*'
    footnotes_perform!
    @controller.response.body.should eql HTML_DOCUMENT
  end

  specify "footnotes_not_included_when_content_type_is_javascript" do
    @controller.response.content_type = 'text/javascript'
    footnotes_perform!
    @controller.response.body.should eql HTML_DOCUMENT
  end

  specify "footnotes_included_when_content_type_is_html" do
    @controller.response.content_type = 'text/html'
    footnotes_perform!
    @controller.response.body.should_not eql HTML_DOCUMENT
  end

  specify "footnotes_included_when_content_type_is_nil" do
    footnotes_perform!
    @controller.response.body.should_not eql HTML_DOCUMENT
  end

  specify "not_included_when_body_is_not_a_string" do
    @controller.response.stub(:body).and_return(Time.now)# = Proc.new { Time.now }
    Footnotes::Filter.new(@controller).send(:valid?).should_not be
    @controller.response.body.should_not =~ /<!-- Footnotes/
  end

  specify "notes_are_initialized" do
    footnotes_perform!
    test_note = @footnotes.instance_variable_get('@notes').first
    test_note.class.name.should eql 'Footnotes::Notes::TestNote'
    test_note.to_sym.should eql :test
  end

  specify "notes_links" do
    note = Footnotes::Notes::TestNote.new
    note.should_receive(:row).twice
    @footnotes.instance_variable_set(:@notes, [note])
    footnotes_perform!
  end

  specify "notes_fieldset" do
    note = Footnotes::Notes::TestNote.new
    note.should_receive(:has_fieldset?).exactly(3).times
    @footnotes.instance_variable_set(:@notes, [note])
    footnotes_perform!
  end

  specify "multiple_notes" do
    Footnotes::Filter.multiple_notes = true
    note = Footnotes::Notes::TestNote.new
    note.should_receive(:has_fieldset?).twice
    @footnotes.instance_variable_set(:@notes, [note])
    footnotes_perform!
  end

  specify "notes_are_reset" do
    note = Footnotes::Notes::TestNote.new
    note.class.should_receive(:close!)
    @footnotes.instance_variable_set(:@notes, [note])
    @footnotes.send(:close!, @controller)
  end

  specify "links_helper" do
    note = Footnotes::Notes::TestNote.new
    @footnotes.send(:link_helper, note).should eql '<a href="#" onclick="">Test</a>'

    note.should_receive(:link).once.and_return(:link)
    @footnotes.send(:link_helper, note).should eql '<a href="link" onclick="">Test</a>'
  end

  specify "links_helper_has_fieldset?" do
    note = Footnotes::Notes::TestNote.new
    note.should_receive(:has_fieldset?).once.and_return(true)
    @footnotes.send(:link_helper, note).should eql '<a href="#" onclick="Footnotes.hideAllAndToggle(\'test_debug_info\');return false;">Test</a>'
  end

  specify "links_helper_onclick" do
    note = Footnotes::Notes::TestNote.new
    note.should_receive(:onclick).twice.and_return(:onclick)
    @footnotes.send(:link_helper, note).should eql '<a href="#" onclick="onclick">Test</a>'

    note.should_receive(:has_fieldset?).once.and_return(true)
    @footnotes.send(:link_helper, note).should eql '<a href="#" onclick="onclick">Test</a>'
  end

  specify "insert_style" do
    @controller.response.body = "<head></head><split><body></body>"
    @footnotes = Footnotes::Filter.new(@controller)
    footnotes_perform!
    @controller.response.body.split('<split>').first.include?('<!-- Footnotes Style -->').should be
  end

  specify "insert_footnotes_inside_body" do
    @controller.response.body = "<head></head><split><body></body>"
    @footnotes = Footnotes::Filter.new(@controller)
    footnotes_perform!
    @controller.response.body.split('<split>').last.include?('<!-- End Footnotes -->').should be
  end

  specify "insert_footnotes_inside_holder" do
    @controller.response.body = "<head></head><split><div id='footnotes_holder'></div>"
    @footnotes = Footnotes::Filter.new(@controller)
    footnotes_perform!
    @controller.response.body.split('<split>').last.include?('<!-- End Footnotes -->').should be
  end

  specify "insert_text" do
    @footnotes.send(:insert_text, :after, /<head>/, "Graffiti")
    after = "    <head>Graffiti"
    @controller.response.body.split("\n")[2].should eql after

    @footnotes.send(:insert_text, :before, /<\/body>/, "Notes")
    after = "    Notes</body>"
    @controller.response.body.split("\n")[12].should eql after
  end

  describe 'Hooks' do
    before {Footnotes::Filter.notes = [:note_x, :note_y, :note_z]}
    context 'before' do
      specify do
        Footnotes.setup {|config| config.before {|controller, filter| filter.notes -= [:note_y] }}
        Footnotes::Filter.start!(@controller)
        Footnotes::Filter.notes.should eql [:note_x, :note_z]
      end
    end
    context "after" do
      specify do
        Footnotes.setup {|config| config.after {|controller, filter| filter.notes -= [:note_y] }}
        Footnotes::Filter.start!(@controller)
        Footnotes::Filter.notes.should eql [:note_x, :note_z]
      end
    end
  end

  protected
  def footnotes_perform!
    template_expects('html')
    @controller.performed_render = true

    Footnotes::Filter.start!(@controller)
    @footnotes.add_footnotes!
  end

  def template_expects(format)
    if @controller.template.respond_to?(:template_format)
      @controller.template.stub(:template_format).and_return(format)
    else
      @controller.template.stub(:format).and_return(format)
    end
  end

HTML_DOCUMENT = <<EOF
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
EOF

end
