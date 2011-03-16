require 'test/unit'
require 'rubygems'
require 'mocha'

ENV['RAILS_ENV'] = 'test'

require 'active_support'
require 'active_support/all' unless Class.respond_to?(:cattr_accessor)
require 'rails-footnotes/footnotes'
require 'rails-footnotes/notes/abstract_note'