# -*- coding: utf-8 -*-
framework 'Foundation'

module Salut

# Advertises its service on the local network using Bonjour.
class Service

  # @return [String] service_type
  attr_accessor :service_type

  # @return [String] instance_name
  attr_accessor :instance_name

  # @return [Fixnum] port
  attr_accessor :port

  # @return [NSNetService]
  attr_reader :service

  # @return [Hash{Symbol=>Proc}]
  attr_accessor :delegates

  # @param [Symbol] key
  # @return [Proc]
  def [] key
    @delegates[key]
  end

  # @param [Symbol] key
  # @param [Proc] value
  # @return [Proc]
  def []= key, value
    @delegates[key] = value
  end

  # @example Initializing with a hash
  #  service = Advertiser.new({
  #    service_type:'_http._tcp.',
  #    instance_name:'Test',
  #    port:3000
  #  })
  # @param [Hash{Symbol=>String,Fixnum}] params key-value pairs specifying the
  #  type, name, and port for the service
  def initialize params = {}
    @service_type  = params[:service_type]
    @instance_name = params[:instance_name]
    @port          = params[:port]
    @delegates     = {}
  end

  # Create a new NSNetService instance and publish to the local network.
  # @return [NSNetService] the service that began advertising
  def start_advertising domain_name = ''
    @service = NSNetService.alloc.initWithDomain domain_name,
                                            type:@service_type,
                                            name:@instance_name,
                                            port:@port
    @service.delegate = self
    @service.publish
  end

  # @param [Float] timeout number of seconds to wait before timing out
  def resolve timeout = 60.0
    @service.resolveWithTimeout timeout
  end

  # @return [NSNetService] the service that just stopped advertising
  def stop_advertising
    @service.stop
    @service = nil
  end


  ### delegate methods

  # @return [nil]
  def netServiceWillPublish sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Starting to advertise service (#{sender.description})")
  end

  # @param [Hash] error_dict
  # @return [nil]
  def netService sender, didNotPublish:error_dict
    @delegates[__method__].call sender, error_dict if @delegates[__method__]
    NSLog("ERROR: could not advertise service (#{sender.description})\n\t the problem was\n#{error_dict.description}")
  end

  # @return [nil]
  def netServiceDidPublish sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Successfully advertising service (#{sender.description})")
  end

  # @return [nil]
  def netServiceWillResolve sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Resolving service (#{sender.description})")
  end

  # @param [Hash] error_dict
  # @return [nil]
  def netService sender, didNotResolve:error_dict
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("ERROR: could not resolve service (#{sender.description})\n\t the problem was\n#{error_dict.description}")
  end

  # @return [nil]
  def netServiceDidResolveAddress sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Resolved address for service (#{sender.description})")
  end

  # @param [NSData] data the new TXT record
  # @return [nil]
  def netService sender, didUpdateTXTRecordData:data
    @delegates[__method__].call sender, data if @delegates[__method__]
    NSLog("Updated TXT record for service (#{sender.description})")
  end

  # @return [nil]
  def netServiceDidStop sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Stopped advertising service (#{sender.description})")
  end
end


# Browses the local network for other MCTestHarness instances and
# maintains a list of all the services it finds. Uses Bonjour to
# do the heavy lifting.
#
# You should be careful not to reuse the same instance for multiple
# searches without calling #stop, you are likely to get an error
# logged. The reason for this is that a browser never really stops
# searching (unless you call #stop), even if moreComing is false;
# moreComing is more of a signal that the browser up to date on
# the network state for the moment but network state changes will
# trigger the callback.
class Browser

  # @return [Array<String>]
  attr_reader :domains

  # @return [Array<NSNetService>]
  attr_reader :services

  # @return [Hash{Symbol=>Proc}]
  attr_accessor :delegates

  # @param [Symbol] key
  # @return [Proc]
  def [] key
    @delegates[key]
  end

  # @param [Symbol] key
  # @param [Proc] value
  # @return [Proc]
  def []= key, value
    @delegates[key] = value
  end

  def initialize
    @browser   = NSNetServiceBrowser.new
    @browser.delegate = self
    @domains   = []
    @services  = []
    @delegates = {}
  end

  # @return [nil]
  def find_browsable_domains
    @browser.searchForBrowsableDomains
  end

  # @param [String] service_name
  # @param [String] domain_name
  def find_services service_name, in_domain:domain_name
    @browser.searchForServicesOfType service_name, inDomain:domain_name
  end

  # @return [nil]
  def stop_searching
    @browser.stop
  end


  ### delegates

  # @return [nil]
  def netServiceBrowser sender, didFindDomain:domain_name, moreComing:more
    @domains << domain_name
    @delegates[__method__].call sender, domain_name, more if @delegates[__method__]
    NSLog("Found domain: #{domain_name}")
  end

  # @return [nil]
  def netServiceBrowser sender, didRemoveDomain:domain_name, moreComing:more
    @domains.delete domain_name
    @delegates[__method__].call sender, domain_name, more if @delegates[__method__]
    NSLog("Removing domain: #{domain_name}")
  end

  # @return [nil]
  def netServiceBrowser sender, didFindService:service, moreComing:more
    @services << service
    puts __method__
    @delegates[__method__].call sender, service, more if @delegates[__method__]
    NSLog("Found service (#{service.description})")
  end

  # @return [nil]
  def netServiceBrowser sender, didRemoveService:service, moreComing:more
    @services.delete service
    @delegates[__method__].call sender, service, more if @delegates[__method__]
    NSLog("Removing service (#{service.description})")
  end

  # @return [nil]
  def netServiceBrowserWillSearch sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Starting search (#{sender.description})")
  end

  # @return [nil]
  def netServiceBrowser sender, didNotSearch:error_dict
    @delegates[__method__].call sender, error_dict if @delegates[__method__]
    NSLog("Failed to search (#{sender.description})\n\t problem was\n#{error_dict.description}")
  end

  # @return [nil]
  def netServiceBrowserDidStopSearch sender
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Done searching (#{sender.description})")
  end
end

end
