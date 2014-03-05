require 'active_support/concern'

module Footnotes
  module RailsFootnotesExtension

    extend ActiveSupport::Concern

    included do
      prepend_before_filter :rails_footnotes_before_filter
      after_filter :rails_footnotes_after_filter
    end

    def rails_footnotes_before_filter
      if Footnotes.enabled?
        Footnotes::Filter.start!(self)
      end
    end

    def rails_footnotes_after_filter
      if Footnotes.enabled?
        filter = Footnotes::Filter.new(self)
        filter.add_footnotes!
        filter.close!(self)
      end
    end
  end
end
