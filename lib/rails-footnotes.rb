require 'rails'
require 'action_controller'
require 'rails-footnotes/abstract_note'
require 'rails-footnotes/each_with_rescue'
require 'rails-footnotes/filter'
require 'rails-footnotes/notes/all'
require 'rails-footnotes/extension'
require 'active_support/deprecation'

module Footnotes
  mattr_accessor :before_hooks
  @@before_hooks = []

  mattr_accessor :after_hooks
  @@after_hooks = []

  mattr_accessor :enabled
  @@enabled = false

  class << self
    delegate :notes, :to => Filter
    delegate :notes=, :to => Filter

    delegate :prefix, :to => Filter
    delegate :prefix=, :to => Filter

    delegate :no_style, :to => Filter
    delegate :no_style=, :to => Filter

    delegate :multiple_notes, :to => Filter
    delegate :multiple_notes=, :to => Filter

    delegate :lock_top_right, :to => Filter
    delegate :lock_top_right=, :to => Filter

    delegate :font_size, :to => Filter
    delegate :font_size=, :to => Filter
  end

  def self.run!
    ActiveSupport::Deprecation.warn "run! is deprecated and will be removed from future releases, use Footnotes.setup or Footnotes.enabled instead.", caller
    Footnotes.enabled = true
  end

  def self.before(&block)
    @@before_hooks << block
  end

  def self.after(&block)
    @@after_hooks << block
  end

  def self.enabled?(controller)
    if @@enabled.is_a? Proc
      if @@enabled.arity == 1
        @@enabled.call(controller)
      else
        @@enabled.call
      end
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
