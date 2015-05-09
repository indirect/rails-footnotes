require "spec_helper"
require 'action_controller'
require "rails-footnotes/notes/assigns_note"

describe Footnotes::Notes::AssignsNote do
  let(:note) do
    @controller = double
    allow(@controller).to receive(:instance_variables).and_return([:@action_has_layout, :@status])
    @controller.instance_variable_set(:@action_has_layout, true)
    @controller.instance_variable_set(:@status, 200)
    Footnotes::Notes::AssignsNote.new(@controller)
  end
  subject {note}

  before(:each) {Footnotes::Notes::AssignsNote.ignored_assigns = []}

  it {should be_valid}

  describe '#title' do
    subject { super().title }
    it {should eql 'Assigns (2)'}
  end

  specify {expect(note.send(:assigns)).to eql [:@action_has_layout, :@status]}
  specify {expect(note.send(:to_table)).to eql [
    ["Name", "Value"],
    ["<strong>@action_has_layout</strong><br /><em>TrueClass</em>", "true"],
    ["<strong>@status</strong><br /><em>Fixnum</em>", "200"]
  ]}

  describe "Ignored Assigns" do
    before(:each) {Footnotes::Notes::AssignsNote.ignored_assigns = [:@status]}
    it {expect(note.send(:assigns)).not_to include :@status}
  end

  describe "Ignored Assigns by regexp" do
    before(:each) {Footnotes::Notes::AssignsNote.ignored_assigns_pattern = /^@status$/}
    it {expect(note.send(:assigns)).not_to include :@status}
  end

  it "should call #mount_table method with correct params" do
    expect(note).to receive(:mount_table).with(
      [
        ["Name", "Value"],
        ["<strong>@action_has_layout</strong><br /><em>TrueClass</em>", "true"],
        ["<strong>@status</strong><br /><em>Fixnum</em>", "200"]
      ], {:summary=>"Debug information for Assigns (2)"})
    note.content
  end
end
