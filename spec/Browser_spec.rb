require './spec_helper'
require 'StringIO'

describe Salut::Browser do
  before do
    Salut.log.level = Logger::WARN
    @browser = Salut::Browser.new
  end

  describe '#searching?' do
    it 'should be initialized to false' do
      @browser.searching?.should.be.equal false
    end

    it 'should be false after I stop searching' do
      @browser.find_services '_ssh._tcp.', in_domain:''
      run_run_loop 1
      @browser.searching?.should.be.equal true

      @browser.stop_finding_services
      run_run_loop 1
      @browser.searching?.should.be.equal false

      @browser.find_browsable_domains
      run_run_loop 1
      @browser.searching?.should.be.equal true

      @browser.stop_finding_domains
      run_run_loop 1
      @browser.searching?.should.be.equal false
    end

    # I don't know how to cause a failure when searching
    # for browsable domains
    it 'should be false if searching fails' do
      @browser.find_services 'badname', in_domain:''
      run_run_loop
      @browser.searching?.should.be.equal false
    end

    it 'should be true when searching starts' do
      @browser.find_services '_ssh._tcp.', in_domain:''
      @browser.searching?.should.be.equal true

      @browser.stop_finding_services
      run_run_loop 1
      @browser.searching?.should.be.equal false

      @browser.find_browsable_domains
      @browser.searching?.should.be.equal true
    end
  end


  describe '#domains' do
    it 'should be initialized to an empty array' do
      @browser.domains.class.should.be.equal Array
      @browser.domains.should.be.equal []
    end

    # here I assume that local. will always be found
    it 'should be populated with domains when I browse for domains' do
      @browser.domains.size.should.be.equal 0
      @browser.find_browsable_domains
      run_run_loop
      @browser.domains.size.should.not.be.equal 0
    end

    # @todo not sure how to fake this one
    it 'should shrink when domains disappear' do
    end
  end

end
