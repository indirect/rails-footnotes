require 'spec_helper'

class PartialsController < ActionController::Base

  def index
  end

end

describe PartialsController, type: :controller do

  render_views

  before :all do
    Footnotes.enabled = true
  end

  after :all do
    Footnotes.enabled = false
  end

  it 'lists the rendered partials' do
    get :index
    expect(response.body).to have_selector('#footnotes_debug #partials_debug_info table tr', :visible => false, :count => 2)
  end


end
