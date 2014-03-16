require 'spec_helper'

class PartialsController < ActionController::Base

  def index
    prepend_view_path "#{Rails.root.join('spec', 'views')}"
  end

end

describe PartialsController do

  render_views

  before :all do
    Footnotes.enabled = true
  end

  after :all do
    Footnotes.enabled = false
  end

  it 'lists the rendered partials' do
    get :index
    response.body.should have_selector('#footnotes_debug #partials_debug_info table tr', :visible => false, :count => 2)
  end


end
