require 'spec_helper'
require 'action_controller'
require "rails-footnotes/notes/files_note"

describe Footnotes::Notes::FilesNote do

  let(:note) do
    Rails.stub(:version).and_return('3.0.12');
    Footnotes::Notes::FilesNote.new(double('controller', :response => double('', :body => '')))
  end

  subject { note }

  it { should be_valid }
  its(:row) { should eql :edit }

end
