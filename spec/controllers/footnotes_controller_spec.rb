require 'spec_helper'

class FootnotesController < ActionController::Base

  def foo
    render :text => HTML_DOCUMENT, :content_type => 'text/html'
  end

  def foo_holder
    render :text => '<html><body><div id="footnotes_holder"></div></body></html>'
  end

  def foo_js
    render :text => '<script></script>', :content_type => 'text/javascript'
  end

  def foo_download
    send_file Rails.root.join('spec', 'fixtures', 'html_download.html'), :disposition => 'attachment'
  end

end

describe FootnotesController do

  def page
    Capybara::Node::Simple.new(response.body)
  end

  shared_examples 'has_footnotes' do
    it 'includes footnotes' do
      get :foo
      response.body.should have_selector('#footnotes_debug')
    end
  end

  shared_examples 'has_no_footnotes' do
    it 'does not include footnotes' do
      response.body.should_not have_selector('#footnotes_debug')
    end
  end

  it 'does not alter the page by default' do
    get :foo
    response.body.should == HTML_DOCUMENT
  end

  context 'with footnotes' do

    before :all do
      Footnotes.enabled = true
    end

    after :all do
      Footnotes.enabled = false
    end

    describe 'by default' do
      include_context 'has_footnotes'

      before do
        get :foo
      end

      it 'includes footnotes in the last div in body' do
        all('body > :last-child')[0][:id].should == 'footnotes_debug'
      end

      it 'includes footnotes in the footnoted_holder div if present' do
        get :foo_holder
        response.body.should have_selector('#footnotes_holder > #footnotes_debug')
      end

      it 'does not alter a html file download' do
        get :foo_download
        response.body.should == File.open(Rails.root.join('spec', 'fixtures', 'html_download.html')).read
      end
    end

    describe 'when request is xhr' do
      include_context 'has_no_footnotes'
      before do
        xhr :get, :foo
      end
    end

    describe 'when content type is javascript' do
      include_context 'has_no_footnotes'
      before do
        get :foo_js
      end
    end

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
