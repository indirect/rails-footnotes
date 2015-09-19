require 'active_support/concern'

module Footnotes
  module RailsFootnotesExtension

    extend ActiveSupport::Concern

    included do
      prepend_before_action :rails_footnotes_before_action
      after_action :rails_footnotes_after_action
    end

    def rails_footnotes_before_action
      if Footnotes.enabled?(self)
        Footnotes::Filter.start!(self)
      end
    end

    def rails_footnotes_after_action
      if Footnotes.enabled?(self)
        filter = Footnotes::Filter.new(self)
        filter.add_footnotes!
        filter.close!(self)
      end
    end
  end
end
