unless defined?(ENABLE_RAILS_FOOTNOTES)
  ENABLE_RAILS_FOOTNOTES=Rails.env.development?
end
if ENABLE_RAILS_FOOTNOTES
  require 'rails-footnotes/footnotes'
  require 'rails-footnotes/backtracer'

  # Load all notes
  dir = File.dirname(__FILE__)
  Dir[File.join(dir, 'rails-footnotes', 'notes', '*.rb')].sort.each do |note|
    require note
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
