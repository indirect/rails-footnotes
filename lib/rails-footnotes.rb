module Footnotes
  
  # The footnotes are applied by default to all actions. You can change this
  # behavior commenting the after_filter line below and putting it in Your
  # application. Then you can cherrypick in which actions it will appear.
  #
  module RailsFootnotesExtension
    def self.included(base)
      base.prepend_before_filter Footnotes::BeforeFilter
      base.after_filter Footnotes::AfterFilter
    end
  end
  
  def self.run!
    require 'rails-footnotes/footnotes'
    require 'rails-footnotes/backtracer'
     
    Dir[File.join(File.dirname(__FILE__), 'rails-footnotes', 'notes', '*.rb')].each { |note| require note }
    
    ActionController::Base.send(:include, RailsFootnotesExtension)    
  end
end
