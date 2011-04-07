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

require 'rubygems/builder'
require 'rubygems/installer'
spec = Gem::Specification.load('Salut.gemspec')

desc 'Build the gem'
task :build do Gem::Builder.new(spec).build end

desc 'Build the gem and install it'
task :install => :build do Gem::Installer.new(spec.file_name).install end

