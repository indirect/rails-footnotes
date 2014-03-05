require 'rails'
require 'action_controller'
require 'rails-footnotes/backtracer'
require 'rails-footnotes/abstract_note'
require 'rails-footnotes/each_with_rescue'
require 'rails-footnotes/filter'
require 'rails-footnotes/notes/all'
require 'rails-footnotes/extension'

module Footnotes
  mattr_accessor :before_hooks
  @@before_hooks = []

  mattr_accessor :after_hooks
  @@after_hooks = []

  mattr_accessor :enabled
  @@enabled = false

  def self.before(&block)
    @@before_hooks << block
  end

  def self.after(&block)
    @@after_hooks << block
  end

  def self.enabled?
    if @@enabled.is_a? Proc
      @@enabled.call
    else
      !!@@enabled
    end
  end

  def self.setup
    yield self
  end
end

ActionController::Base.send(:include, Footnotes::RailsFootnotesExtension)

load Rails.root.join('.rails_footnotes') if Rails.root && Rails.root.join('.rails_footnotes').exist?
