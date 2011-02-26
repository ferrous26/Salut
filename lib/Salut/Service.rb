module Salut

  # Advertises its service on the local network using Bonjour or is
  # a service that was found using Sault::Browser.
  #
  # Note that an instance of the service should be used for one or the
  # other, but not both. Some methods are meant for when you are using
  # Service to advertise a service and other methods are meant for when
  # you are working with services that have been discovered.
  class Service

    # @return [Boolean]
    attr_reader :advertising
    alias_method :advertising?, :advertising

    # @return [NSNetService]
    attr_reader :service

    # @return [String]
    attr_accessor :service_type

    # @return [String]
    attr_accessor :instance_name

    # @return [Fixnum]
    attr_accessor :port

    # @example Initializing with properties
    #  service = Advertiser.new({
    #    service_type:'_http._tcp.',
    #    instance_name:'Test',
    #    port:3000
    #  })
    # @example Initializing with an existing service
    #  service = Advertiser.new({
    #    service:NSNetService.alloc.initWithDomain('',
    #                                         type:'_http._tcp.',
    #                                         name:`hostname -s`.chomp,
    #                                         port:3000)
    #  })
    # @param [Hash{Symbol=>(String,Fixnum,NSNetService)}] params
    def initialize params = {}
      @service_type  = params[:service_type]
      @instance_name = params[:instance_name]
      @port          = params[:port]
      @service       = params[:service]
      @delegates     = {}
      @advertising   = false
    end


    # @group Adding callback extensions

    # A shortcut for reading/writing from the delegate methods
    # @param [Symbol] method
    # @return [Proc]
    def delegate method
      if block_given?
        @delegates[method] = Proc.new
      else
        @delegates[method]
      end
    end


    # @group Advertising a service

    # Start advertising the service. If you want to change the service
    # type, instance name, or port, you will have to {#stop_advertising}
    # first.
    #
    # If there is an error creating the underlying NSNetService object
    # (usually because one of @service_type, @instance_name, and @port
    # are not specified) then you will get a NilClass NoMethodError when
    # the method tries to set the delegate.
    # @param [String] domain defaults to all domains
    def start_advertising domain = ''
      @service = NSNetService.alloc.initWithDomain domain,
                                              type:@service_type,
                                              name:@instance_name,
                                              port:@port
      @service.delegate = self
      @service.publish
    end

    # Stop advertising the service, which is a nice thing to do when you
    # are cleaning up before exiting your code, but the script/program
    # exiting will also cause the service to stop being published.
    def stop_advertising
      @service.stop
      @service = nil
    end


    # @group Working with discovered services

    # A more Ruby-like #resolveWithTimeout by supporting a default argument
    # @param [Float] timeout number of seconds to wait before timing out
    def resolve timeout = 60.0
      @service.delegate = self
      @service.resolveWithTimeout timeout
    end


    # @group Delegate methods

    # @yieldparam [Salut::Service] sender a reference to self
    def netServiceWillPublish sender
      @delegates[__method__].call self if @delegates[__method__]
      Salut.log.info "Starting to advertise service (#{sender.description})"
    end

    # @yieldparam [Salut::Service] sender a reference to self
    # @yieldparam [Hash] error_dict
    def netService sender, didNotPublish:error_dict
      @advertising = false
      @delegates[__method__].call self, error_dict if @delegates[__method__]
      Salut.log.info "ERROR: could not advertise service (#{sender.description})\n\t the problem was\n#{error_dict.description}"
    end

    # @yieldparam [Salut::Service] sender a reference to self
    def netServiceDidPublish sender
      @advertising = true
      @delegates[__method__].call self if @delegates[__method__]
      Salut.log.info "Successfully advertising service (#{sender.description})"
    end

    # @yieldparam [Salut::Service] sender a reference to self
    def netServiceWillResolve sender
      @delegates[__method__].call self if @delegates[__method__]
      Salut.log.info "Resolving service (#{sender.description})"
    end

    # @yieldparam [Salut::Service] sender a reference to self
    # @yieldparam [Hash] error_dict
    def netService sender, didNotResolve:error_dict
      @delegates[__method__].call self, error_dict if @delegates[__method__]
      Salut.log.info "ERROR: could not resolve service (#{sender.description})\n\t the problem was\n#{error_dict.description}"
    end

    # @yieldparam [Salut::Service] sender a reference to self
    def netServiceDidResolveAddress sender
      @delegates[__method__].call self if @delegates[__method__]
      Salut.log.info "Resolved address for service (#{sender.description})"
    end

    # @todo should I process the TXT record before giving it to the proc?
    # @yieldparam [Salut::Service] sender a reference to self
    # @yieldparam [NSData] data the new TXT record
    def netService sender, didUpdateTXTRecordData:data
      @delegates[__method__].call self, data if @delegates[__method__]
      Salut.log.info "Updated TXT record for service (#{sender.description})"
    end

    # @yieldparam [Salut::Service] sender a reference to self
    def netServiceDidStop sender
      @advertising = false
      @delegates[__method__].call self if @delegates[__method__]
      Salut.log.info "Stopped advertising/resolving service (#{sender.description})"
    end

  end

end
