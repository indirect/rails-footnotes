require 'simplecov'
SimpleCov.start

require 'rubygems'

ENV['RAILS_ENV'] = 'test'

require 'active_support'
require 'active_support/all' unless Class.respond_to?(:cattr_accessor)
require 'rails-footnotes/footnotes'
require 'rails-footnotes/abstract_note'
require "rails-footnotes"

class Rails
  def self.logger; end
end

RSpec.configure do |config|
end
