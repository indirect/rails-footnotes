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
    send_file Rails.root.join('fixtures', 'html_download.html'), :disposition => 'attachment'
  end

end

describe FootnotesController, type: :controller do

  shared_examples 'has_footnotes' do
    it 'includes footnotes' do
      get :foo
      expect(response.body).to have_selector('#footnotes_debug')
    end
  end

  shared_examples 'has_no_footnotes' do
    it 'does not include footnotes' do
      expect(response.body).not_to have_selector('#footnotes_debug')
    end
  end

  it 'does not alter the page by default' do
    get :foo
    expect(response.body).to eq(HTML_DOCUMENT)
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
        expect(all('body > :last-child')[0][:id]).to eq('footnotes_debug')
      end

      it 'includes footnotes in the footnoted_holder div if present' do
        get :foo_holder
        expect(response.body).to have_selector('#footnotes_holder > #footnotes_debug')
      end

      it 'does not alter a html file download' do
        get :foo_download
        expect(response.body).to eq(File.open(Rails.root.join('fixtures', 'html_download.html')).read)
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

    describe 'when footnotes is disabled' do
      include_context 'has_no_footnotes'
      before do
        Footnotes.enabled = false
        get :foo
      end
    end

    describe 'with a proc' do

      it 'yields the controller' do
        c = nil
        Footnotes.enabled = lambda { |controller| c = controller}
        get :foo
        expect(c).to be_kind_of(ActionController::Base)
      end

      context 'returning true' do
        include_context 'has_footnotes'

        before do
          Footnotes.enabled = lambda { true }
          get :foo
        end
      end

      context 'returning false' do
        include_context 'has_no_footnotes'

        before do
          Footnotes.enabled = lambda { false }
          get :foo
        end
      end

    end

  end

end
