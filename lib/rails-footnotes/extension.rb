require 'active_support/concern'

module Footnotes
  module RailsFootnotesExtension
    extend ActiveSupport::Concern

    included do
      prepend_before_action :rails_footnotes_before_filter
      after_action :rails_footnotes_after_filter
    end

    def rails_footnotes_before_filter
      Footnotes::Filter.start!(self) if Footnotes.enabled?(self)
    end

    def rails_footnotes_after_filter
      return unless Footnotes.enabled?(self)

      filter = Footnotes::Filter.new(self)
      filter.add_footnotes!
      filter.close!(self)
    end
  end
end
