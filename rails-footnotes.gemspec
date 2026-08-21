require_relative "./lib/rails-footnotes/version"

Gem::Specification.new do |s|
  s.name        = "rails-footnotes"
  s.version     = Footnotes::VERSION
  s.authors     = ["Roman V. Babenko", "José Valim", "Keenan Brock", "Duane Johnson", "Adrien Siami", "André Arko"]
  s.email       = ["andre@arko.net"]
  s.homepage    = "https://github.com/indirect/rails-footnotes"
  s.summary     = %q{Every Rails page has footnotes that gives information about your application and links back to your editor.}
  s.description = %q{Every Rails page has footnotes that gives information about your application and links back to your editor.}

  s.add_dependency "rails", ">= 7", "< 9"
  s.required_ruby_version = ">= 3.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files =
    IO.popen(["git", "-C", __dir__, "ls-files", "-z", "--", "exe/", "lib/", "*.md", "*.txt", "CHANGELOG", "*LICENSE"], &:read).split("\x0")
      .reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile Rakefile tasks/])
    end
  s.require_paths = ["lib"]
end
