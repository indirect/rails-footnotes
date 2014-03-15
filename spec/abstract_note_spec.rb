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

  it {described_class.should respond_to :start!}
  it {described_class.should respond_to :close!}
  it {described_class.should respond_to :title}

  it {should respond_to :to_sym}
  its(:to_sym) {should eql :abstract}

  it { described_class.should be_included }
  specify do
    Footnotes::Filter.notes = []
    described_class.should_not be_included
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
  specify { subject.escape('<').should eql '&lt;' }
  specify { subject.escape('&').should eql '&amp;' }
  specify { subject.escape('>').should eql '&gt;' }

  specify { subject.mount_table([]).should be_blank }
  specify { subject.mount_table([['h1', 'h2', 'h3']], :class => 'table').should be_blank }

  specify {
    tab = <<-TABLE
          <table class="table" >
            <thead><tr><th>H1</th></tr></thead>
            <tbody><tr><td>r1c1</td></tr></tbody>
          </table>
          TABLE

    subject.mount_table([['h1'],['r1c1']], :class => 'table').should eql tab
  }

  specify {
    tab = <<-TABLE
          <table >
            <thead><tr><th>H1</th><th>H2</th><th>H3</th></tr></thead>
            <tbody><tr><td>r1c1</td><td>r1c2</td><td>r1c3</td></tr></tbody>
          </table>
          TABLE
    subject.mount_table([['h1', 'h2', 'h3'],['r1c1', 'r1c2', 'r1c3']]).should eql tab
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
