Gem::Specification.new do |s|
  s.name     = "rails-footnotes"
  s.version  = "3.3.2"
  s.date     = "2009-01-04"
  s.summary  = "Every Rails page has footnotes that gives information about your application and links back to your editor."
  s.email    = "jose.valim@gmail.com"
  s.homepage = "http://github.com/josevalim/rails-footnotes"
  s.description = "Every Rails page has footnotes that gives information about your application and links back to your editor."
  s.has_rdoc = true
  s.authors  = [ "José Valim" ]
  s.files    = [
    "MIT-LICENSE",
    "README",
    "Rakefile",
    "lib/rails-footnotes.rb",
    "lib/backtracer/backtracer.rb",
    "lib/footnotes/footnotes.rb",
    "lib/notes/abstract_note.rb",
    "lib/notes/components_note.rb",
    "lib/notes/controller_note.rb",
    "lib/notes/cookies_note.rb",
    "lib/notes/env_note.rb",
    "lib/notes/files_note.rb",
    "lib/notes/filters_note.rb",
    "lib/notes/general_note.rb",
    "lib/notes/javascripts_note.rb",
    "lib/notes/layout_note.rb",
    "lib/notes/log_note.rb",
    "lib/notes/params_note.rb",
    "lib/notes/queries_note.rb",
    "lib/notes/routes_note.rb",
    "lib/notes/session_note.rb",
    "lib/notes/stylesheets_note.rb",
    "lib/notes/view_note.rb",
    "test/footnotes_test.rb",
    "test/test_helper.rb",
    "test/notes/abstract_note_test.rb"
  ]
  s.test_files = [
    "test/footnotes_test.rb",
    "test/test_helper.rb",
    "test/notes/abstract_note_test.rb"
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
end
