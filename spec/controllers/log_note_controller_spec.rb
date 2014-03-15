require 'spec_helper'
require 'stringio'

describe 'log note' do

  class ApplicationController < ActionController::Base
  end

  controller do
    def index
      Rails.logger.error 'foo'
      Rails.logger.warn 'bar'
      render :text => '<html><head></head><body></body></html>', :content_type => 'text/html'
    end
  end

  def page
    Capybara::Node::Simple.new(response.body)
  end

  before :all do
    Footnotes.enabled = true
  end

  after :all do
    Footnotes.enabled = false
  end

  before do
    @original_logger = Rails.logger
    Rails.logger = Logger.new(StringIO.new)
  end

  after do
    Rails.logger = @original_logger
  end

  it 'Includes the log in the response' do
    get :index
    log_debug = first('fieldset#log_debug_info div', :visible => false)
    log_debug.should have_content('foo')
    log_debug.should have_content('bar')
  end

end
