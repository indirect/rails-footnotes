require "spec_helper"
require "rails-footnotes/notes/view_note"

describe Footnotes::Notes::ViewNote do

  it "should not be valid if view file not exist" do
    note = Footnotes::Notes::ViewNote.new(double)
    note.stub(:filename).and_return(nil)

    note.should_not be_valid
  end
end
