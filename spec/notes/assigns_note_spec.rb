require "spec_helper"
require 'action_controller'
require "rails-footnotes/notes/assigns_note"

class FootnotesController < ActionController::Base
end

describe Footnotes::Notes::AssignsNote do
  let(:note) do
    @controller = FootnotesController.new
    Footnotes::Notes::AssignsNote.new(@controller)
  end
  subject {note}

  before(:each) {Footnotes::Notes::AssignsNote.ignored_assigns = []}
  it {should be_valid}
  its(:title) {should eql 'Assigns (3)'}
  specify {note.send(:assigns).should eql [:@action_has_layout, :@view_context_class, :@_status] }

  describe "Ignored Assigns" do
    before(:each) {Footnotes::Notes::AssignsNote.ignored_assigns = [:@_status]}
    it {note.send(:assigns).should_not include :@_status}
  end
end
