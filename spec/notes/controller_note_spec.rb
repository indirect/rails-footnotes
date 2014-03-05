require "spec_helper"
require "rails-footnotes/notes/controller_note"

describe Footnotes::Notes::ControllerNote do
  # Issue #60
  it "should not be valid if conftroller file not exist" do
    note = Footnotes::Notes::ControllerNote.new(double)
    note.stub(:controller_filename).and_return(nil)

    note.should_not be_valid
  end
end
