require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "rails-footnotes"
    s.version = "3.6.7"
    s.rubyforge_project = "rails-footnotes"
    s.summary = "Every Rails page has footnotes that gives information about your application and links back to your editor."
    s.email = "keenan@thebrocks.net"
    s.homepage = "http://github.com/josevalim/rails-footnotes"
    s.description = "Every Rails page has footnotes that gives information about your application and links back to your editor."
    s.authors = ['Keenan Brock']
    s.files =  FileList["[A-Z]*", "{lib}/**/*"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end

desc 'Run tests for Footnotes.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
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

begin
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
      #skipping: churn, :stats
      config.metrics  = [:saikuro, :flog, :flay, :reek, :roodi, :rcov]
      # config.graphs   = [:flog, :flay, :reek, :roodi, :rcov]
      config.rcov[:rcov_opts] << "-Itest"
  end
rescue LoadError
end
