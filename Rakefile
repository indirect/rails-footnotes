require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "rails-footnotes"
    s.version = "3.6.4"
    s.rubyforge_project = "rails-footnotes"
    s.summary = "Every Rails page has footnotes that gives information about your application and links back to your editor."
    s.email = "jose@plataformatec.com.br"
    s.homepage = "http://github.com/josevalim/rails-footnotes"
    s.description = "Every Rails page has footnotes that gives information about your application and links back to your editor."
    s.authors = ['José Valim']
    s.files =  FileList["[A-Z]*", "{lib}/**/*"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Run tests for Footnotes.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for Footnotes.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Footnotes'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
