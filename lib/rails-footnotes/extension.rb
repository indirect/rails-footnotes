module Footnotes
  module RailsFootnotesExtension
    def self.included(base)
      base.prepend_before_filter Footnotes::BeforeFilter
      base.after_filter Footnotes::AfterFilter
    end
  end
end
