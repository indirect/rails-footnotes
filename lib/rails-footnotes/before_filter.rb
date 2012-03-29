module Footnotes
  class BeforeFilter
    # Method called to start the notes
    # It's a before filter prepend in the controller
    def self.filter(controller)
      Footnotes::Filter.start!(controller)
    end
  end
end
