module Footnotes
  mattr_accessor :before_hooks
  @@before_hooks = []

  mattr_accessor :after_hooks
  @@after_hooks = []

  def self.before(&block)
    @@before_hooks << block
  end

  def self.after(&block)
    @@after_hooks << block
  end

  autoload :RailsFootnotesExtension, 'rails-footnotes/extension'

  def self.run!
    require 'rails-footnotes/footnotes'
    require 'rails-footnotes/backtracer'
    require 'rails-footnotes/abstract_note'
    require 'rails-footnotes/notes/all'

    ActionController::Base.send(:include, RailsFootnotesExtension)

    load Rails.root.join('.rails_footnotes') if Rails.root.join('.rails_footnotes').exist?
    #TODO DEPRECATED
    load Rails.root.join('.footnotes') if Rails.root.join('.footnotes').exist?
  end

  def self.setup
    yield self
  end
end
