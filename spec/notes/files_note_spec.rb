require 'spec_helper'
require 'action_controller'
require "rails-footnotes/notes/files_note"

describe Footnotes::Notes::FilesNote do
  let(:note) {Footnotes::Notes::FilesNote.new(mock('controller', :response => mock('', :body => '')))}
  subject {note}

  it {should be_valid}
  its(:row) {should eql :edit}
end
