begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end
ENV["RAILS_ENV"] ||= 'test'
require "sprockets/railtie"
require "rails-footnotes"
require 'capybara/rspec'

module FooBar
  class Application < Rails::Application
    config.secret_key_base = 'foobar'
    config.root = Dir.new('./spec')
    config.eager_load = false
  end
end

ActionController::Base.class_eval do
  include Rails.application.routes.url_helpers
end

class ApplicationController < ActionController::Base
end

module Helpers
  def page
    Capybara::Node::Simple.new(response.body)
  end
end

RSpec.configure do |config|

  Rails.application.initialize!

  config.include Capybara::DSL
  config.include Helpers

  Rails.application.routes.draw do
    get 'footnotes/foo'
    get 'footnotes/foo_holder'
    get 'footnotes/foo_js'
    get 'footnotes/foo_download'
    get 'partials/index'
    get 'files/index'
  end
end

require 'rspec/rails'
require 'capybara/rails'

HTML_DOCUMENT = <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <head>
        <title>HTML to XHTML Example: HTML page</title>
        <link rel="Stylesheet" href="htmltohxhtml.css" type="text/css" media="screen">
        <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
    </head>
    <body>
        <p>This is the HTML page. It works and is encoded just like any HTML page you
         have previously done. View <a href="htmltoxhtml2.htm">the XHTML version</a> of
         this page to view the difference between HTML and XHTML.</p>
        <p>You will be glad to know that no changes need to be made to any of your CSS files.</p>
    </body>
</html>
EOF
