# -*- coding: utf-8 -*-
framework 'Foundation'

require   'Salut/Browser'

# Various modules intended to be mixed in to classes that use
module Salut

# Advertises its service on the local network using Bonjour.
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

  # @return [Hash{Symbol=>Proc}]
  attr_accessor :delegates

  # A shortcut for reading from the delegate methods
  # @param [Symbol] key
  # @return [Proc]
  def [] key
    @delegates[key]
  end

  # A shortcut for writing to the delegate methods hash
  # @param [Symbol] key
  # @param [Proc] value
  # @return [Proc]
  def []= key, value
    @delegates[key] = value
  end

  # @endgroup


  # @group Advertising a service

  # Start advertising the service. If you want to change the service
  # type, instance name, or port, you will have to {#stop_advertising}
  # first.
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
    @service     = nil
  end

  # @endgroup


  # @group Working with discovered services

  # A more Ruby-like #resolveWithTimeout by supporting a default argument
  # @param [Float] timeout number of seconds to wait before timing out
  def resolve timeout = 60.0
    @service.resolveWithTimeout timeout
  end

  # @endgroup


  # @group Delegate methods

  # @yieldparam [NSNetService] sender
  # @return [nil]
  def netServiceWillPublish sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Starting to advertise service (#{sender.description})")
  end

  # @yieldparam [NSNetService] sender
  # @yieldparam [Hash] error_dict
  # @return [nil]
  def netService sender, didNotPublish:error_dict
    @advertising = false
    @delegates[__method__].call sender, error_dict if @delegates[__method__]
    NSLog("ERROR: could not advertise service (#{sender.description})\n\t the problem was\n#{error_dict.description}")
  end

  # @yieldparam [NSNetService] sender
  # @return [nil]
  def netServiceDidPublish sender
    @advertising = true
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Successfully advertising service (#{sender.description})")
  end

  # @yieldparam [NSNetService] sender
  # @return [nil]
  def netServiceWillResolve sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Resolving service (#{sender.description})")
  end

  # @yieldparam [NSNetService] sender
  # @yieldparam [Hash] error_dict
  # @return [nil]
  def netService sender, didNotResolve:error_dict
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("ERROR: could not resolve service (#{sender.description})\n\t the problem was\n#{error_dict.description}")
  end

  # @yieldparam [NSNetService] sender
  # @return [nil]
  def netServiceDidResolveAddress sender
    # @todo fill out local variables
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Resolved address for service (#{sender.description})")
  end

  # @yieldparam [NSNetService] sender
  # @yieldparam [NSData] data the new TXT record
  # @return [nil]
  def netService sender, didUpdateTXTRecordData:data
    @delegates[__method__].call sender, data if @delegates[__method__]
    NSLog("Updated TXT record for service (#{sender.description})")
  end

  # @yieldparam [NSNetService] sender
  # @return [nil]
  def netServiceDidStop sender
    @advertising = false
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Stopped advertising service (#{sender.description})")
  end

  # @endgroup

end

end
