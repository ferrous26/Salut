require 'rubygems'
require 'rake'

task :default => :spec
task :test    => :spec

desc 'Run tests with MacBacon'
task :spec do
  sh 'macbacon --automatic spec/*_spec.*rb'
end

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
