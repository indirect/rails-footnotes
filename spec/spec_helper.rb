begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'rubygems'
require 'rails/all'
ENV['RAILS_ENV'] = 'test'
Rails.logger = Logger.new(STDOUT)

require 'active_support'
require 'active_support/all' unless Class.respond_to?(:cattr_accessor)
require 'rails-footnotes/footnotes'
require 'rails-footnotes/abstract_note'
require "rails-footnotes"

RSpec.configure do |config|
end

module FooBar
  class Application < Rails::Application
    config.secret_key_base = 'foobar'
  end
end
