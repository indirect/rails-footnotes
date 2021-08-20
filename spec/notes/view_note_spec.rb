require "spec_helper"
require "rails-footnotes/notes/view_note"

describe Footnotes::Notes::ViewNote do
  it "should not be valid if view file not exist" do
    note = Footnotes::Notes::ViewNote.new(double)
    allow(note).to receive(:filename).and_return(nil)

    expect(note).not_to be_valid
  end

  it "should not explode if template is nil" do
    Footnotes::Notes::ViewNote.template = nil

    note = Footnotes::Notes::ViewNote.new(double)
    expect(note).to_not be_valid
  end
end
