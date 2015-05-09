require "spec_helper"

describe Footnotes::Notes::AbstractNote do
  before do
    @note = Footnotes::Notes::AbstractNote.new
    @notes = Footnotes::Filter.notes
    Footnotes::Filter.notes = [:abstract]
  end

  after do
    Footnotes::Filter.notes = @notes
  end

  it {expect(described_class).to respond_to :start!}
  it {expect(described_class).to respond_to :close!}
  it {expect(described_class).to respond_to :title}

  it {should respond_to :to_sym}

  describe '#to_sym' do
    subject { super().to_sym }
    it {should eql :abstract}
  end

  it { expect(described_class).to be_included }
  specify do
    Footnotes::Filter.notes = []
    expect(described_class).not_to be_included
  end

  it { should respond_to :row }
  it { should respond_to :legend }
  it { should respond_to :link }
  it { should respond_to :onclick }
  it { should respond_to :stylesheet }
  it { should respond_to :javascript }

  it { should respond_to :valid? }
  it { should be_valid }

  it { should respond_to :has_fieldset? }
  it { should_not have_fieldset }

  specify { Footnotes::Filter.prefix = ''; should_not be_prefix }
  specify do
    Footnotes::Filter.prefix = 'txmt://open?url=file://%s&amp;line=%d&amp;column=%d'
    should be_prefix
  end

  #TODO should be moved to builder
  #helpers
  specify { expect(subject.escape('<')).to eql '&lt;' }
  specify { expect(subject.escape('&')).to eql '&amp;' }
  specify { expect(subject.escape('>')).to eql '&gt;' }

  specify { expect(subject.mount_table([])).to be_blank }
  specify { expect(subject.mount_table([['h1', 'h2', 'h3']], :class => 'table')).to be_blank }

  specify {
    tab = <<-TABLE
          <table class="table" >
            <thead><tr><th>H1</th></tr></thead>
            <tbody><tr><td>r1c1</td></tr></tbody>
          </table>
          TABLE

    expect(subject.mount_table([['h1'],['r1c1']], :class => 'table')).to eql tab
  }

  specify {
    tab = <<-TABLE
          <table >
            <thead><tr><th>H1</th><th>H2</th><th>H3</th></tr></thead>
            <tbody><tr><td>r1c1</td><td>r1c2</td><td>r1c3</td></tr></tbody>
          </table>
          TABLE
    expect(subject.mount_table([['h1', 'h2', 'h3'],['r1c1', 'r1c2', 'r1c3']])).to eql tab
  }

  specify {
    tab = <<-TABLE
          <table >
            <thead><tr><th>H1</th><th>H2</th><th>H3</th></tr></thead>
            <tbody><tr><td>r1c1</td><td>r1c2</td><td>r1c3</td></tr><tr><td>r2c1</td><td>r2c2</td><td>r2c3</td></tr></tbody>
          </table>
          TABLE
    subject.mount_table([['h1', 'h2', 'h3'], ['r1c1', 'r1c2', 'r1c3'], ['r2c1', 'r2c2', 'r2c3']])
  }
end
