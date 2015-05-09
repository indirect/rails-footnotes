require 'bundler'
Bundler::GemHelper.install_tasks
require "rspec/core/rake_task"
require 'rdoc/task'

desc 'Default: run tests'
task :default => :spec
RSpec::Core::RakeTask.new(:spec)

desc 'Generate documentation for Footnotes.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Footnotes'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
