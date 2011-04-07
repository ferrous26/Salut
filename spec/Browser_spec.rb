require 'spec/spec_helper'

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
      @browser.find_services '_ssh._tcp.'
      run_run_loop
      @browser.searching?.should.be.equal true

      @browser.stop_finding_services
      run_run_loop
      @browser.searching?.should.be.equal false

      @browser.find_browsable_domains
      run_run_loop
      @browser.searching?.should.be.equal true

      @browser.stop_finding_domains
      run_run_loop
      @browser.searching?.should.be.equal false
    end

    # I don't know how to cause a failure when searching
    # for browsable domains
    it 'should be false if searching fails' do
      @browser.find_services 'badname'
      run_run_loop
      @browser.searching?.should.be.equal false
    end

    it 'should be true when searching starts' do
      @browser.find_services '_ssh._tcp.'
      @browser.searching?.should.be.equal true

      @browser.stop_finding_services
      run_run_loop
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
    it 'should shrink when domains disappear'
  end


  describe '#services' do
    before do
      @service = Salut::Service.new(
        service_type:'_test._tcp.',
        instance_name:'TEST',
        port:9000
      )
      @service.start_advertising
      run_run_loop
    end

    it 'should be initialized to an empty array' do
      @browser.services.class.should.be.equal Array
      @browser.services.should.be.equal []
    end

    it 'should populate when I call #find_services' do
      @browser.services.size.should.be.equal 0
      @browser.find_services '_test._tcp.'
      run_run_loop
      @browser.services.size.should.not.be.equal 0
    end

    it 'should dispopulate if services go away after being discovered by calling #find_services' do
      @browser.services.size.should.be.equal 0
      @browser.find_services '_test._tcp.'
      run_run_loop
      @browser.services.size.should.be.equal 1
      @service.stop_advertising
      run_run_loop
      @browser.services.size.should.be.equal 0
    end
  end


  describe '#browser' do
    it 'should be the underlying NSNetServiceBrowser' do
      @browser.browser.class.should.be.equal NSNetServiceBrowser
    end

    it 'should be set at initialization' do
      @browser.browser.should.not.be.equal nil
    end
  end


  describe '#initialize' do
    it 'should initialize browser with an NSNetServiceBrowser' do
      @browser.browser.should.not.be.equal nil
    end

    it 'should initialize #domains to an empty array' do
      @browser.domains.should.be.equal []
    end

    it 'should initialize #services to an empty array' do
      @browser.services.should.be.equal []
    end

    it 'should initialize #searching? to false' do
      @browser.searching?.should.be.equal false
    end
  end
end
