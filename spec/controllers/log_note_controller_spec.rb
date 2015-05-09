require 'spec_helper'
require 'stringio'

describe 'log note', type: :controller do

  class ApplicationController < ActionController::Base
  end

  controller do
    def index
      Rails.logger.error 'foo'
      Rails.logger.warn 'bar'
      render :text => '<html><head></head><body></body></html>', :content_type => 'text/html'
    end
  end

  before :all do
    Footnotes.enabled = true
  end

  after :all do
    Footnotes.enabled = false
  end

  it 'Includes the log in the response' do
    get :index
    log_debug = first('fieldset#log_debug_info div', :visible => false)
    expect(log_debug).to have_content('foo')
    expect(log_debug).to have_content('bar')
  end

end
