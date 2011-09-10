module RailsFootnotes
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates and copy RailsFootnotes default files to your application."

      def copy_initializer
        template "rails_footnotes.rb", "config/initializers/rails_footnotes.rb"
      end

      def copy_dotfile
        template "rails_footnotes", ".rails_footnotes"
      end
    end
  end
end
