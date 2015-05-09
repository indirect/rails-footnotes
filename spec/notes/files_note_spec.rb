require 'spec_helper'
require 'action_controller'
require "rails-footnotes/notes/files_note"

describe Footnotes::Notes::FilesNote do

  let(:note) do
    Footnotes::Notes::FilesNote.new(double('controller', :response => double('', :body => '')))
  end

  subject { note }

  it { should be_valid }

  describe '#row' do
    subject { super().row }
    it { should eql :edit }
  end

end
