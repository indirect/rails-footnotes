require 'spec_helper'
require 'action_controller'
require "rails-footnotes/notes/files_note"

class ConcreteFilesNote < Footnotes::Notes::FilesNote
  def scan_text(text)
    []
  end
end

describe Footnotes::Notes::FilesNote do

  let(:note) do
    ConcreteFilesNote.new(double('controller', :response => double('', :body => '')))
  end

  subject { note }

  it { should be_valid }

  describe '#row' do
    subject { super().row }
    it { should eql :edit }
  end

end
