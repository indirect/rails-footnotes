require 'active_support/concern'

module Footnotes
  module RailsFootnotesExtension

    extend ActiveSupport::Concern

    included do
      if Rails::VERSION::MAJOR >= 5
        prepend_before_action :rails_footnotes_before_filter
        after_action :rails_footnotes_after_filter
      else
        prepend_before_filter :rails_footnotes_before_filter
        after_filter :rails_footnotes_after_filter
      end
    end

    def rails_footnotes_before_filter
      if Footnotes.enabled?(self)
        Footnotes::Filter.start!(self)
      end
    end

    def rails_footnotes_after_filter
      if Footnotes.enabled?(self)
        filter = Footnotes::Filter.new(self)
        filter.add_footnotes!
        filter.close!(self)
      end
    end
  end
end
