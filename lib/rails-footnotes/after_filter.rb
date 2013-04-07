module Footnotes
  class AfterFilter
    # Method that calls Footnotes to attach its contents
    def self.after(controller)
      filter = Footnotes::Filter.new(controller)
      filter.add_footnotes!
      filter.close!(controller)
    end
  end
end
