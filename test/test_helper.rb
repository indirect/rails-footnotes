require 'test/unit'
require 'rubygems'
require 'mocha'

ENV['RAILS_ENV'] = 'test'

require 'active_support'
require File.dirname(__FILE__) + '/../lib/rails-footnotes/footnotes'
require File.dirname(__FILE__) + '/../lib/rails-footnotes/notes/abstract_note'