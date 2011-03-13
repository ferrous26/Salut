$LOAD_PATH.unshift File.join( File.dirname(__FILE__), 'lib' )
require 'Salut/Version'

Gem::Specification.new do |s|
  s.name    = 'Salut'
  s.version = Salut::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 1.4.2')
  s.rubygems_version          = '1.4.2'

  s.summary       = 'A simple example of using Bonjour with MacRuby'
  s.description   =<<-EOS
Uses the Objective-C NetService classes to advertise and discover services on the local network
  EOS
  s.authors       = ['Mark Rada']
  s.email         = 'marada@uwaterloo.ca'
  s.homepage      = 'http://github.com/ferrous26/Salut'
  s.licenses      = ['MIT']
  s.has_rdoc      = 'yard'
  s.require_paths = ['lib']

  s.files            = [
                        'lib/Salut.rb',
                        'lib/Salut/Browser.rb',
                        'lib/Salut/Service.rb'
                       ]
  s.test_files       = [
                        'spec/spec_helper.rb',
                        'spec/Browser_spec.rb',
                        'spec/Service_spec.rb'
                       ]
  s.extra_rdoc_files = [
                        'LICENSE.txt',
                        'README.markdown'
                       ]

  s.add_development_dependency 'yard',      ['~> 0.6.4']
  s.add_development_dependency 'bluecloth', ['~> 2.0.11']
  s.add_development_dependency 'mac_bacon', ['~> 1.3.0']
end

