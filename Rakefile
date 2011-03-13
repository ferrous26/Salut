require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

namespace :gem do

  desc 'Build the gem'
  task :build do
    puts `gem build -v Salut.gemspec`
  end

  desc 'Install the gem in the current directory with the highest version number'
  task :install => :build do
    puts `gem install #{Dir.glob('*.gem').sort.reverse.first}`
  end

end
