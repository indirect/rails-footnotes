require 'rails'
require 'action_controller'
require 'rails-footnotes/footnotes'
require 'rails-footnotes/backtracer'
require 'rails-footnotes/abstract_note'
require 'rails-footnotes/notes/all'

module Footnotes
  mattr_accessor :before_hooks
  @@before_hooks = []

  mattr_accessor :after_hooks
  @@after_hooks = []

  @@enabled = false

  def self.before(&block)
    @@before_hooks << block
  end

  def self.after(&block)
    @@after_hooks << block
  end

  autoload :RailsFootnotesExtension, 'rails-footnotes/extension'

  def enabled?
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
