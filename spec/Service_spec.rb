require './spec_helper'

describe Salut::Service do
  before do
    Salut.log.level = Logger::WARN
  end

  describe '#advertising?' do
    before do
      @service = Salut::Service.new({
        port:3000,
        instance_name:'Test',
        service_type:'_http._tcp.'
      })
    end

    it 'should be initialized to false' do
      @service.advertising?.should.be.equal false
    end

    it 'should be false when I start advertising (until #netServiceDidPublish is called)' do
      @service.start_advertising
      @service.advertising?.should.be.equal false
    end

    it 'should be false after I stop advertising' do
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @service.stop_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @service.advertising?.should.be.equal false
    end

    it 'should be false if advertising fails' do
      @other_service = @service.dup
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @other_service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @other_service.advertising?.should.be.equal false
    end

    it 'should be true when advertising is successful' do
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @service.advertising?.should.be.equal true
    end
  end


  describe '#service' do
    before do
      @service = Salut::Service.new({
        port:3000,
        instance_name:'Test',
        service_type:'_http._tcp.'
      })
    end

    it 'is an NSNetService instance when not nil' do
      @service.start_advertising
      @service.service.class.should.be.equal NSNetService
    end

    it 'can be set at initialization' do
      new_service = NSNetService.alloc.initWithDomain '',
                                                 type:'_http._tcp.',
                                                 name:'TEST',
                                                 port:4000
      @service = Salut::Service.new({ service:new_service })
      @service.service.should.be.equal new_service
    end

    it 'will be created when advertising starts' do
      @service.service.should.be.equal nil
      @service.start_advertising
      @service.service.should.not.be.equal nil
    end

    it 'will be set to nil when advertising stops' do
      @service.service.should.be.equal nil
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate (Time.now + 5)
      @service.stop_advertising
      @service.service.should.be.equal nil
    end
  end


  describe '#initialize' do
    it 'will let you initialize the port number' do
      Salut::Service.new({ port:4000 }).port.should.be.equal 4000
    end

    it 'will let you initialize the instance name' do
      Salut::Service.new({ instance_name:'TEST' }).instance_name.should.be.equal 'TEST'
    end

    it 'will let you initialize the service type' do
      Salut::Service.new({ service_type:'_http._tcp.' }).service_type.should.be.equal '_http._tcp.'
    end

    it 'will let you initialize with a service' do
      new_service = NSNetService.alloc.initWithDomain '',
                                                 type:'_http._tcp.',
                                                 name:'TEST',
                                                 port:4000
      @service = Salut::Service.new({ service:new_service })
      @service.service.should.be.equal new_service
    end

    it 'will initialize delegates to an empty hash' do
      Salut::Service.new.delegates.should.be.equal Hash.new
    end

    it 'will initialize @advertising to false' do
      Salut::Service.new.advertising?.should.be.equal false
    end

    it 'will let you initialize with nothing being set' do
      @service = Salut::Service.new
      @service.should.not.be.equal nil
    end
  end


  describe '#delegates' do
    it 'should be initialized to an empty hash' do
      Salut::Service.new.delegates.should.be.equal Hash.new
    end

    it 'should be writable' do
      @service = Salut::Service.new
      @service.delegates[:test] = Proc.new { true }
      @service.delegates[:test].should.not.be.equal nil
    end
  end


  describe '#[]' do
    it 'should be equivalent to #delegates[]' do
      @service = Salut::Service.new
      @service.delegates[:test] = 'HEY'
      @service[:test].should.be.equal 'HEY'
    end
  end


  describe '#[]=' do
    it 'should be equivalent to #delegates[]=' do
      @service = Salut::Service.new
      @service[:test] = 'HEY'
      @service.delegates[:test].should.be.equal 'HEY'
    end
  end


  describe '#start_advertising' do
    before do
      @service = Salut::Service.new({
        instance_name:'TEST',
        service_type:'_test._tcp.',
        port:9001
      })
    end

    it 'should create a new @service object' do
      @service.service.should.be.equal nil
      @service.start_advertising
      @service.service.should.not.be.equal nil
    end

    it 'should set the delegate for @service to self' do
      @service.delegates[:'netServiceWillPublish:'] = Proc.new { |sender|
        @service.service.should.be.equal sender
      }
      @service.start_advertising
    end

    # a fragile test since it depends on one of the callbacks
    # being called
    it 'should call #publish on @service' do
      @service.delegates[:'netServiceWillPublish:'] = Proc.new { |sender|
        @service.service.should.be.equal sender
      }
      @service.start_advertising
    end

    it 'should set domain to an empty string by default' do
      @service.start_advertising
      @service.service.domain.should.be.equal ''
    end

    it 'should allow me to specify a domain' do
      @service.start_advertising 'local.'
      @service.service.domain.should.be.equal 'local.'
    end

    it 'should fail if service type, instance name, or port are not set' do
      @service.service_type = nil
      should.raise(NoMethodError) { @service.start_advertising }
    end
  end


  describe '#stop_advertising' do
    before do
      @service = Salut::Service.new({
        instance_name:'TEST',
        service_type:'_test._tcp.',
        port:9001
      })
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 3
    end

    # a fragile test since it depends on one of the callbacks
    # being called
    it 'should call #stop on @service' do
      @service.delegates[:'netServiceDidStop:'] = Proc.new { |sender|
        true.should.be.equal true
      }
      @service.stop_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 3
    end

    it 'should set @service to nil' do
      @service.service.should.not.be.equal nil
      @service.stop_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 3
      @service.service.should.be.equal nil
    end
  end

end
