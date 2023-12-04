require "spec_helper"
require "action_controller"
require "rails-footnotes/notes/assigns_note"
require "support/active_record"

describe Footnotes::Notes::AssignsNote do
  let(:controller) do
    double(instance_variables: [:@action_has_layout, :@status]).tap do |c|
      c.instance_variable_set(:@action_has_layout, true)
      c.instance_variable_set(:@status, 200)
    end
  end
  subject(:note) { Footnotes::Notes::AssignsNote.new(controller) }

  before(:each) {Footnotes::Notes::AssignsNote.ignored_assigns = []}

  it { should be_valid }

  describe '#title' do
    subject { super().title }
    it {should eql 'Assigns (2)'}
  end

  specify {expect(note.send(:assigns)).to eql [:@action_has_layout, :@status]}
  specify {expect(note.send(:to_table)).to eql [
    ["Name", "Value"],
    ["<strong>@action_has_layout</strong><br /><em>TrueClass</em>", "true"],
    ["<strong>@status</strong><br /><em>Integer</em>", "200"]
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
        ["<strong>@status</strong><br /><em>Integer</em>", "200"]
      ], {:summary=>"Debug information for Assigns (2)"})
    note.content
  end

  describe "when it is an ActiveRecord::Relation" do
    let(:controller) do
      double(instance_variables: [:@widgets]).tap do |c|
        c.instance_variable_set(:@widgets, Widget.all)
      end
    end

    it "should still work" do
      expect(note).to receive(:mount_table).with(
        [
          ["Name", "Value"],
          ["<strong>@widgets</strong><br /><em>ActiveRecord::Relation</em>", "#&lt;ActiveRecord::Relation []&gt;"],
        ], {:summary=>"Debug information for Assigns (1)"})
      expect(note).to be_valid
      note.content
    end
  end
end
