Gem::Specification.new do |s|
  s.name     = "rails-footnotes"
  s.version  = "3.6.1"
  s.date     = "2009-06-12"
  s.summary  = "Every Rails page has footnotes that gives information about your application and links back to your editor."
  s.email    = "jose.valim@gmail.com"
  s.homepage = "http://github.com/josevalim/rails-footnotes"
  s.description = "Every Rails page has footnotes that gives information about your application and links back to your editor."
  s.has_rdoc = true
  s.authors  = [ "José Valim" ]
  s.files    = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README",
    "Rakefile",
    "lib/rails-footnotes.rb",
    "lib/rails-footnotes/backtracer.rb",
    "lib/rails-footnotes/footnotes.rb",
    "lib/rails-footnotes/notes/abstract_note.rb",
    "lib/rails-footnotes/notes/assigns_note.rb",
    "lib/rails-footnotes/notes/controller_note.rb",
    "lib/rails-footnotes/notes/cookies_note.rb",
    "lib/rails-footnotes/notes/env_note.rb",
    "lib/rails-footnotes/notes/files_note.rb",
    "lib/rails-footnotes/notes/filters_note.rb",
    "lib/rails-footnotes/notes/general_note.rb",
    "lib/rails-footnotes/notes/javascripts_note.rb",
    "lib/rails-footnotes/notes/layout_note.rb",
    "lib/rails-footnotes/notes/log_note.rb",
    "lib/rails-footnotes/notes/params_note.rb",
    "lib/rails-footnotes/notes/queries_note.rb",
    "lib/rails-footnotes/notes/routes_note.rb",
    "lib/rails-footnotes/notes/rpm_note.rb",
    "lib/rails-footnotes/notes/session_note.rb",
    "lib/rails-footnotes/notes/stylesheets_note.rb",
    "lib/rails-footnotes/notes/view_note.rb"
  ]
  s.test_files = [
    "test/footnotes_test.rb",
    "test/test_helper.rb",
    "test/notes/abstract_note_test.rb"
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
end
