begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end
ENV["RAILS_ENV"] ||= 'test'
require "rails-footnotes"
Rails.logger = Logger.new(STDOUT)

module FooBar
  class Application < Rails::Application
    config.secret_key_base = 'foobar'
    config.root = Dir.new('.')
  end
end

ActionController::Base.class_eval do
  include Rails.application.routes.url_helpers
end

RSpec.configure do |config|

  Rails.application.routes.draw do
    get 'footnotes/foo'
    get 'footnotes/foo_holder'
    get 'footnotes/foo_js'
    get 'footnotes/foo_download'
    get 'partials/index'
  end

end

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
