require_relative "./lib/rails-footnotes/version"

Gem::Specification.new do |s|
  s.name        = "rails-footnotes"
  s.version     = Footnotes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Roman V. Babenko", "José Valim", "Keenan Brock", "Duane Johnson", "Adrien Siami", "André Arko"]
  s.email       = ["andre@arko.net"]
  s.homepage    = "https://github.com/indirect/rails-footnotes"
  s.summary     = %q{Every Rails page has footnotes that gives information about your application and links back to your editor.}
  s.description = %q{Every Rails page has footnotes that gives information about your application and links back to your editor.}

  s.add_dependency "rails", "~> 7.0"
  s.required_ruby_version = ">= 3.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
