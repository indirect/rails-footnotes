require 'spec_helper'
require 'action_controller'
require 'action_controller/test_case'

class FootnotesEnvController < ActionController::Base
  attr_accessor :template, :performed_render
end

describe Footnotes::Notes::EnvNote do
  let(:controller) {
    FootnotesEnvController.new.tap { |c|
      c.template = Object.new
      c.request = ActionController::TestRequest.new
      c.response = ActionController::TestResponse.new
      c.response_body = %Q(<html><body></body></html>)
      c.params = {}
    }
  }

  subject { described_class.new(controller) }

  before do
    @notes = Footnotes::Filter.notes
    Footnotes::Filter.notes = [ :env ]
  end

  after do
    Footnotes::Filter.notes = @notes
  end

  it '#to_sym is :env' do
    expect(subject.to_sym).to eq(:env)
  end

  context 'with non-spec env keys' do
    before :each do
      controller.request.env.replace(:non_spec => 'symbol_env')
    end

    it 'does not raise an exception' do
      expect { subject.content }.not_to raise_error
    end

    it 'includes the environment row' do
      expect(subject).to receive(:mount_table).
        with([ [ :key, 'value' ], [ 'non_spec', 'symbol_env' ] ])
      subject.content
    end
  end

  it 'includes values for all of the keys except HTTP_COOKIE' do
    env = controller.request.env.dup
    env.delete('HTTP_COOKIE')

    env_data = env.map { |k, v| [ k.to_s, subject.escape(v.to_s) ] }.
      sort.
      unshift([ :key, 'value' ])

    expect(subject).to receive(:mount_table).with(env_data)
    subject.content
  end

  it 'gets a link for HTTP_COOKIE' do
    controller.request.env.replace('HTTP_COOKIE' => 'foo')
    expect(subject).to receive(:mount_table).
      with([
        [ :key, 'value' ],
        [ 'HTTP_COOKIE',
          '<a href="#" style="color:#009" onclick="Footnotes.hideAllAndToggle(\'cookies_debug_info\');return false;">See cookies on its tab</a>' ]
    ])
    subject.content
  end
end
