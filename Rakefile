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
  gem.files = ['lib/**/*.rb']
  gem.add_development_dependency "yard", "~> 0.6.0"
  gem.add_development_dependency "bluecloth", "~> 2.0.0"
  gem.add_development_dependency "jeweler", "~> 1.5.1"
  gem.add_development_dependency "mac_bacon", "~> 1.1.21"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

task :default => :spec


require 'yard'
YARD::Rake::YardocTask.new
