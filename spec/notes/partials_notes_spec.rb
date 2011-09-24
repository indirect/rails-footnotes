require "spec_helper"
require "rails-footnotes/notes/partials_note"

describe Footnotes::Notes::PartialsNote do
  let(:note) {described_class.new(mock())}
  subject {note}

  it {should be_valid}
end
