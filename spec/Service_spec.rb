require './spec_helper'
require 'StringIO'

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
      run_run_loop
      @service.stop_advertising
      run_run_loop
      @service.advertising?.should.be.equal false
    end

    it 'should be false if advertising fails' do
      @service.service_type = 'badname'
      @service.start_advertising
      run_run_loop
      @service.advertising?.should.be.equal false
    end

    it 'should be true when advertising is successful' do
      @service.start_advertising
      run_run_loop
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
      run_run_loop 5
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
        @service.should.be.equal sender
      }
      @service.start_advertising
    end

    # a fragile test since it depends on one of the callbacks
    # being called
    it 'should call #publish on @service' do
      @service.delegates[:'netServiceWillPublish:'] = Proc.new { |sender|
        @service.should.be.equal sender
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
      run_run_loop
    end

    it 'should set @service to nil' do
      @service.service.should.not.be.equal nil
      @service.stop_advertising
      run_run_loop
      @service.service.should.be.equal nil
    end
  end


  describe '#resolve' do
    before do
      @service = Salut::Service.new({
        instance_name:'TEST',
        service_type:'_test._tcp.',
        port:9001
      })
      @service.start_advertising
      @browser = Salut::Browser.new
      run_run_loop
    end

    # a fragile test since it depends on callbacks of callbacks being called
    it 'should cause the resolve callback to be called' do
      @browser.delegates[:'netServiceBrowser:didFindService:moreComing:'] = Proc.new {
        |sender, service, more|
        service.delegates[:'netServiceWillResolve:'] = Proc.new { |sender|
          true.should.be.equal true
        }
        service.resolve
      }
      @browser.find_services '_test._tcp.', in_domain:''
      run_run_loop
    end

    it 'should allow me to override the timeout' do
      @browser.delegates[:'netServiceBrowser:didFindService:moreComing:'] = Proc.new {
        |sender, service, more|
        service.delegates[:'netServiceWillResolve:'] = Proc.new { |sender|
          true.should.be.equal true
        }
        service.resolve 2.0
      }
      @browser.find_services '_test._tcp.', in_domain:''
      run_run_loop
    end
  end


  describe 'callback skeletons' do

    before do
      @output         = StringIO.new
      Salut.log       = Logger.new @output
      Salut.log.level = Logger::INFO

      @service = Salut::Service.new({
        service_type:'_test._tcp.',
        instance_name:'TEST',
        port:9001
      })
    end


    describe '#netServiceWillPublish' do
      it 'should call its proc if exists' do
        @service.delegates[:'netServiceWillPublish:'] = Proc.new { |sender|
          true.should.be.equal true
        }
        @service.start_advertising
      end

      it 'should not explode if the proc does not exist' do
        @service.start_advertising
        true.should.be.equal true #if we got here we didn't explode
      end

      it 'should log a message at the INFO level' do
        @service.start_advertising
        @output.string.should.match /Starting to advertise/
      end

      it 'should pass self to the proc' do
        @service.delegates[:'netServiceWillPublish:'] = Proc.new { |sender|
          sender.should.be.equal @service
        }
        @service.start_advertising
      end
    end


    describe '#netService:didNotPublish:' do
      before do
        @service.service_type = 'badname' # this is how we make publishing fail
      end

      it 'should call its proc if exists' do
        @service.delegates[:'netService:didNotPublish:'] = Proc.new { |sender, dict|
          true.should.be.equal true
        }
        @service.start_advertising
        run_run_loop
      end

      it 'should not explode if the proc does not exist' do
        @service.start_advertising
        run_run_loop
        true.should.be.equal true
      end

      it 'should log a message at the INFO level' do
        @service.start_advertising
        run_run_loop
        @output.string.should.match /ERROR: could not advertise/
      end

      it '@advertising will still be false' do
        @service.start_advertising
        run_run_loop
        @service.advertising.should.be.equal false
      end

      it 'should pass self to the proc' do
        @service.delegates[:'netService:didNotPublish:'] = Proc.new { |sender, dict|
          sender.should.be.equal @service
        }
        @service.start_advertising
        run_run_loop
      end

      it 'should pass the error dict to the proc' do
        @service.delegates[:'netService:didNotPublish:'] = Proc.new { |sender, dict|
          dict.class.should.be.equal Hash
          dict['NSNetServicesErrorCode'].should.not.be.equal nil
        }
        @service.start_advertising
        run_run_loop
      end
    end


    describe '#netServiceDidPublish' do
      it 'should call its proc if exists' do
        @service.delegates[:'netServiceDidPublish:'] = Proc.new { |sender|
          true.should.be.equal true
        }
        @service.start_advertising
        run_run_loop
      end

      it 'should not explode if the proc does not exist' do
        @service.start_advertising
        run_run_loop
        true.should.be.equal true
      end

      it 'should log a message at the INFO level' do
        @service.start_advertising
        run_run_loop
        @output.string.should.match /Successfully advertising/
      end

      it 'should set @advertising to true' do
        @service.start_advertising
        run_run_loop
        @service.advertising.should.be.equal true
      end

      it 'should pass self to the proc' do
        @service.delegates[:'netServiceDidPublish:'] = Proc.new { |sender|
          sender.should.be.equal @service
        }
        @service.start_advertising
        run_run_loop
      end
    end


    describe '#netServiceWillResolve' do
      before do
        @service.start_advertising
        @browser = Salut::Browser.new
        @browser.find_services '_test._tcp.', in_domain:''
        run_run_loop
        @found_service = @browser.services.first
      end

      it 'should call its proc if it exists' do
        @found_service.delegates[:'netServiceWillResolve:'] = Proc.new { |sender|
          true.should.be.equal true
        }
        @found_service.resolve
      end

      it 'should not explode if the proc does not exist' do
        @found_service.resolve
        true.should.be.equal true
      end

      it 'should log a message at the INFO level' do
        @found_service.resolve
        @output.string.should.match /Resolving service/
      end

      it 'should pass self to the proc' do
        @found_service.delegates[:'netServiceWillResolve:'] = Proc.new { |sender|
          @found_service.should.be.equal sender
        }
        @found_service.resolve
      end
    end


    # Spitting in the face of my own documentation. Why? Because I want the
    # the code to fail and this is the easiest way to make it happen.
    describe '#netService:didNotResolve:' do
      before do
        @service.start_advertising
      end

      it 'should call its proc if it exists' do
        @service.delegates[:'netService:didNotResolve:'] = Proc.new { |sender, dict|
          true.should.be.equal true
        }
        @service.resolve 1
        run_run_loop
      end

      it 'should not explode if the proc does not exist' do
        @service.resolve 1
        run_run_loop
        true.should.be.equal true
      end

      it 'should log a message at the INFO level' do
        @service.resolve 1
        run_run_loop
        @output.string.should.match /ERROR: could not resolve/
      end

      it 'should pass self to the proc' do
        @service.delegates[:'netService:didNotResolve:'] = Proc.new { |sender, dict|
          sender.should.be.equal @service
        }
        @service.resolve 1
        run_run_loop
      end

      it 'should pass the error dict to the proc' do
        @service.delegates[:'netService:didNotResolve:'] = Proc.new { |sender, dict|
          dict.class.should.be.equal Hash
        }
        @service.resolve 1
        run_run_loop
      end
    end


    describe '#netServiceDidResolveAddress' do
      before do
        @service.start_advertising
        @browser = Salut::Browser.new
        @browser.find_services '_test._tcp.', in_domain:''
        run_run_loop
        @found_service = @browser.services.first
      end

      it 'should call its proc if it exists' do
        @found_service.delegates[:'netServiceDidResolveAddress:'] = Proc.new { |sender|
          true.should.be.equal true
        }
        @found_service.resolve
        run_run_loop
      end

      it 'should not explode if the proc does not exist' do
        @found_service.resolve
        run_run_loop
        true.should.be.equal true
      end

      it 'should log a message at the INFO level' do
        @found_service.resolve
        run_run_loop
        @output.string.should.match /Resolved address for service/
      end

      it 'should pass self to the proc' do
        @found_service.delegates[:'netServiceDidResolveAddress:'] = Proc.new { |sender|
          @found_service.should.be.equal sender
        }
        @found_service.resolve
        run_run_loop
      end
    end
  end


end
