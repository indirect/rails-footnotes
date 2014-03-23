module RailsFootnotes
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Copy rails-footnotes initializer to your application."

      def copy_initializer
        template "rails_footnotes.rb", "config/initializers/rails_footnotes.rb"
      end

    end
  end
end
