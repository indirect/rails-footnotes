require "spec_helper"
require "rails-footnotes/notes/controller_note"

describe Footnotes::Notes::ControllerNote do
  # Issue #60
  it "should not be valid if conftroller file not exist" do
    note = Footnotes::Notes::ControllerNote.new(double)
    allow(note).to receive(:controller_filename).and_return(nil)

    expect(note).not_to be_valid
  end
end
