require 'spec_helper'

class FilesController < ApplicationController

    def index
    end
  end

describe FilesController, type: :controller do
  render_views

  before :all do
    Footnotes.enabled = true
  end

  after :all do
    Footnotes.enabled = false
  end

  it 'includes stylesheets assets in the response' do
    get :index
    js_debug = first('fieldset#javascripts_debug_info div', visible: false)
    expect(js_debug).to have_selector('li a', visible: false, count: 1)
    expect(js_debug).to have_selector('li a', text: /foobar\.js/, visible: false)
    link = js_debug.first('a', visible: false)
    expect(link['href']).to eq("txmt://open?url=file://#{Rails.root.join('app', 'assets', 'javascripts', 'foobar.js')}&line=1&column=1")
  end

  it 'includes css assets in the response' do
    get :index
    css_debug = first('fieldset#stylesheets_debug_info div', visible: false)
    expect(css_debug).to have_selector('li a', visible: false, count: 1)
    expect(css_debug).to have_selector('li a', text: /foobar\.css/, visible: false)
    link = css_debug.first('a', visible: false)
    expect(link['href']).to eq("txmt://open?url=file://#{Rails.root.join('app', 'assets', 'stylesheets', 'foobar.css')}&line=1&column=1")
  end

end
