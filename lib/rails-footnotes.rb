if RAILS_ENV == 'development'
  dir = File.dirname(__FILE__)
  require File.join(dir, 'rails-footnotes', 'footnotes')
  require File.join(dir, 'rails-footnotes', 'backtracer')

  # Load all notes
  #
  Dir[File.join(dir, 'rails-footnotes', 'notes', '*.rb')].each do |note|
    require note  unless note =~ /queries/ && !defined?(ActiveRecord)
  end

  # The footnotes are applied by default to all actions. You can change this
  # behavior commenting the after_filter line below and putting it in Your
  # application. Then you can cherrypick in which actions it will appear.
  #
  class ActionController::Base
    prepend_before_filter Footnotes::Filter
    after_filter Footnotes::Filter
  end
end