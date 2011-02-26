require './spec_helper'

describe Salut::Service do
  before do
    Salut.log.level = Logger::WARN
  end

  describe '#advertising?' do
    before do
      @service = Salut::Service.new(
                                    port:3000,
                           instance_name:'Test',
                            service_type:'_http._tcp.'
                                    )
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
      @service = Salut::Service.new(
                                    port:3000,
                           instance_name:'Test',
                            service_type:'_http._tcp.'
                                    )
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
      @service = Salut::Service.new service:new_service
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
      Salut::Service.new( port:4000 ).port.should.be.equal 4000
    end

    it 'will let you initialize the instance name' do
      Salut::Service.new( instance_name:'TEST' ).instance_name.should.be.equal 'TEST'
    end

    it 'will let you initialize the service type' do
      Salut::Service.new( service_type:'_http._tcp.' ).service_type.should.be.equal '_http._tcp.'
    end

    it 'will let you initialize with a service' do
      new_service = NSNetService.alloc.initWithDomain '',
                                                 type:'_http._tcp.',
                                                 name:'TEST',
                                                 port:4000
      @service = Salut::Service.new service:new_service
      @service.service.should.be.equal new_service
    end

    it 'will initialize @advertising to false' do
      Salut::Service.new.advertising?.should.be.equal false
    end

    it 'will let you initialize with nothing being set' do
      @service = Salut::Service.new
      @service.should.not.be.equal nil
    end
  end


  describe '#delegate' do
    before do @service = Salut::Service.new end

    it 'should be writable' do
      @service.delegate :test do true end
      @service.delegate( :test ).call.should.not.be.equal nil

      @service.delegate :test do 'HEY' end
      @service.delegate( :test ).call.should.be.equal 'HEY'
    end

    it 'should be readable' do
      @service.delegate :test do 'HEY' end
      @service.delegate( :test ).call.should.be.equal 'HEY'
    end
  end


  describe '#start_advertising' do
    before do
      @service = Salut::Service.new(
                                    instance_name:'TEST',
                                     service_type:'_test._tcp.',
                                             port:9001
                                    )
    end

    it 'should create a new @service object' do
      @service.service.should.be.equal nil
      @service.start_advertising
      @service.service.should.not.be.equal nil
    end

    it 'should set the delegate for @service to self' do
      @service.delegate :'netServiceWillPublish:' do |sender|
        @service.should.be.equal sender
      end
      @service.start_advertising
    end

    # a fragile test since it depends on one of the callbacks being called
    it 'should call #publish on @service' do
      @service.delegate :'netServiceWillPublish:' do |sender|
        @service.should.be.equal sender
      end
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
      should.raise NoMethodError do @service.start_advertising end
    end
  end


  describe '#stop_advertising' do
    before do
      @service = Salut::Service.new(
                                    instance_name:'TEST',
                                     service_type:'_test._tcp.',
                                             port:9001
                                    )
      @service.start_advertising
      run_run_loop
    end

    # a fragile test since it depends on one of the callbacks being called
    it 'should call #stop on @service' do
      @service.delegate :'netServiceDidStop:' do |sender|
        true.should.be.equal true
      end
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
      @service = Salut::Service.new(
                                    instance_name:'TEST',
                                     service_type:'_test._tcp.',
                                             port:9001
                                    )
      @service.start_advertising
      @browser = Salut::Browser.new
      run_run_loop
    end

    # a fragile test since it depends on callbacks of callbacks being called
    it 'should cause the resolve callback to be called' do
      @browser.delegate :'netServiceBrowser:didFindService:moreComing:' do
        |sender, service, more|
        service.delegate :'netServiceWillResolve:' do |sender|
          true.should.be.equal true
        end
        service.resolve
      end
      @browser.find_services '_test._tcp.'
      run_run_loop
    end

    it 'should allow me to override the timeout' do
      @browser.delegate :'netServiceBrowser:didFindService:moreComing:' do
        |sender, service, more|
        service.delegate :'netServiceWillResolve:' do |sender|
          true.should.be.equal true
        end
        service.resolve 2.0
      end
      @browser.find_services '_test._tcp.'
      run_run_loop
    end
  end


  describe 'callback skeletons' do

    before do
      @output         = StringIO.new
      Salut.log       = Logger.new @output
      Salut.log.level = Logger::INFO

      @service = Salut::Service.new(
                                     service_type:'_test._tcp.',
                                    instance_name:'TEST',
                                             port:9001
                                    )
    end


    describe '#netServiceWillPublish' do
      it 'should call its proc if exists' do
        @service.delegate :'netServiceWillPublish:' do |sender|
          true.should.be.equal true
        end
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
        @service.delegate :'netServiceWillPublish:' do |sender|
          sender.should.be.equal @service
        end
        @service.start_advertising
      end
    end


    describe '#netService:didNotPublish:' do
      before do
        @service.service_type = 'badname' # this is how we make publishing fail
      end

      it 'should call its proc if exists' do
        @service.delegate :'netService:didNotPublish:' do |sender, dict|
          true.should.be.equal true
        end
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
        @service.delegate :'netService:didNotPublish:' do |sender, dict|
          sender.should.be.equal @service
        end
        @service.start_advertising
        run_run_loop
      end

      it 'should pass the error dict to the proc' do
        @service.delegate :'netService:didNotPublish:' do |sender, dict|
          dict.class.should.be.equal Hash
          dict['NSNetServicesErrorCode'].should.not.be.equal nil
        end
        @service.start_advertising
        run_run_loop
      end
    end


    describe '#netServiceDidPublish' do
      it 'should call its proc if exists' do
        @service.delegate :'netServiceDidPublish:' do |sender|
          true.should.be.equal true
        end
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
        @service.delegate :'netServiceDidPublish:' do |sender|
          sender.should.be.equal @service
        end
        @service.start_advertising
        run_run_loop
      end
    end


    describe '#netServiceWillResolve' do
      before do
        @service.start_advertising
        @browser = Salut::Browser.new
        @browser.find_services '_test._tcp.'
        run_run_loop
        @found_service = @browser.services.first
      end

      it 'should call its proc if it exists' do
        @found_service.delegate :'netServiceWillResolve:' do |sender|
          true.should.be.equal true
        end
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
        @found_service.delegate :'netServiceWillResolve:' do |sender|
          @found_service.should.be.equal sender
        end
        @found_service.resolve
      end
    end


    # Spitting in the face of my own documentation. Why? Because I want the
    # the code to fail and this is the easiest way to make it happen.
    describe '#netService:didNotResolve:' do
      before do @service.start_advertising end

      it 'should call its proc if it exists' do
        @service.delegate :'netService:didNotResolve:' do |sender, dict|
          true.should.be.equal true
        end
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
        @service.delegate :'netService:didNotResolve:' do |sender, dict|
          sender.should.be.equal @service
        end
        @service.resolve 1
        run_run_loop
      end

      it 'should pass the error dict to the proc' do
        @service.delegate :'netService:didNotResolve:' do |sender, dict|
          dict.class.should.be.equal Hash
        end
        @service.resolve 1
        run_run_loop
      end
    end


    describe '#netServiceDidResolveAddress' do
      before do
        @service.start_advertising
        @browser = Salut::Browser.new
        @browser.find_services '_test._tcp.'
        run_run_loop
        @found_service = @browser.services.first
      end

      it 'should call its proc if it exists' do
        @found_service.delegate :'netServiceDidResolveAddress:' do |sender|
          true.should.be.equal true
        end
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
        @found_service.delegate :'netServiceDidResolveAddress:' do |sender|
          @found_service.should.be.equal sender
        end
        @found_service.resolve
        run_run_loop
      end
    end


    # describe '#netService:didUpdateTXTRecordData:' do
    #   it 'should call its proc if exists' do
    #   end

    #   it 'should not explode if the proc does not exist' do
    #   end

    #   it 'should log a message at the INFO level' do
    #   end

    #   it 'should pass self to the proc' do
    #   end

    #   it 'should pass the TXT record data to the proc' do
    #   end
    # end


    describe '#netServiceDidStop' do
      before do
        @service.start_advertising
        run_run_loop 1
      end

      it 'should call its proc if exists' do
        @service.delegate :'netServiceDidStop:' do |sender|
          true.should.be.equal true
        end
        @service.stop_advertising
        run_run_loop
      end

      it 'should not explode if the proc does not exist' do
        @service.stop_advertising
        run_run_loop
        true.should.be.equal true
      end

      it 'should log a message at the INFO level' do
        @service.stop_advertising
        run_run_loop
        @output.string.should.match /Stopped advertising/
      end

      it 'should set @advertising to false' do
        @service.advertising?.should.be.equal true
        @service.stop_advertising
        run_run_loop
        @service.advertising?.should.be.equal false
      end

      it 'should pass self to the proc' do
        @service.delegate :'netServiceDidStop:' do |sender|
          sender.should.be.equal @service
        end
        @service.stop_advertising
        run_run_loop
      end
    end

  end


end
