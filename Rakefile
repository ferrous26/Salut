require 'rubygems'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "Salut"
  gem.homepage = "http://github.com/ferrous26/Salut"
  gem.license = "MIT"
  gem.summary = %Q{A simple example of using Bonjour with MacRuby}
  gem.description = %Q{Uses the Objective-C NetService classes to advertise and discover services on the local network}
  gem.email = "marada@uwaterloo.ca"
  gem.authors = ["Mark Rada"]
  gem.add_development_dependency "yard", "~> 0.6.0"
  gem.add_development_dependency "bluecloth", "~> 2.0.0"
  gem.add_development_dependency "jeweler", "~> 1.5.1"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
