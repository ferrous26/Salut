require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

# require 'rcov/rcovtask'
# Rcov::RcovTask.new do |spec|
#   spec.libs << 'spec'
#   spec.pattern = 'spec/**/*_spec.rb'
#   spec.verbose = true
# end

task :default => :spec


require 'yard'
YARD::Rake::YardocTask.new
