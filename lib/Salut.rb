# -*- coding: utf-8 -*-
framework 'Foundation'

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
  # @param [Hash{Symbol=>String,Fixnum}] params key-value pairs specifying the
  #  type, name, and port for the service
  def initialize params = {}
    @service_type  = params[:service_type]
    @instance_name = params[:instance_name]
    @port          = params[:port]
    @service       = params[:service]
    @delegates     = {}
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


# Browsers are used for searching for services and domains. A single instance
# should only be used for a single search.
#
# You should be careful not to reuse the same instance for multiple
# searches without calling {#stop_searching}, otherwise you are likely to get
# an error logged. The reason for this is that a browser never really
# stops searching (unless you call {#stop_searching}), even if moreComing
# is false. moreComing is a signal that the browser up to date on the network
# state for the moment but any new network state changes will trigger the
# callbacks again.
class Browser

  # @return [Boolean]
  attr_reader :searching
  alias_method :searching?, :searching

  # @return [Array<String>]
  attr_reader :domains

  # @return [Array<NSNetService>]
  attr_reader :services

  # Ensure that some instance variables are initialized
  def initialize
    @browser          = NSNetServiceBrowser.alloc.init
    @browser.delegate = self
    @domains          = []
    @services         = []
    @delegates        = {}
  end

  # Stop searching for things, whether they be domains or services
  def stop_finding
    @browser.stop
  end


  # @group Adding callback extensions

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
  # @endgroup


  # @group Finding domains

  # @return [nil]
  def find_browsable_domains
    @browser.searchForBrowsableDomains
  end


  # @endgroup


  # @group Finding services

  # @param [String] service_name
  # @param [String] domain_name
  def find_services service_name, in_domain:domain_name
    @browser.searchForServicesOfType service_name, inDomain:domain_name
  end

  # @return [nil]
  def stop_searching
    @browser.stop
  end

  # @endgroup


  # @group Delegate methods

  # @yieldparam [NSNetServiceBrowser] sender
  # @yieldparam [String] domain_name
  # @yieldparam [Boolean] more
  # @return [nil]
  def netServiceBrowser sender, didFindDomain:domain_name, moreComing:more
    @domains << domain_name
    @delegates[__method__].call sender, domain_name, more if @delegates[__method__]
    NSLog("Found domain: #{domain_name}")
  end

  # @yieldparam [NSNetServiceBrowser] sender
  # @yieldparam [String] domain_name
  # @yieldparam [Boolean] more
  # @return [nil]
  def netServiceBrowser sender, didRemoveDomain:domain_name, moreComing:more
    @domains.delete domain_name
    @delegates[__method__].call sender, domain_name, more if @delegates[__method__]
    NSLog("Removing domain: #{domain_name}")
  end

  # @yieldparam [NSNetServiceBrowser] sender
  # @yieldparam [Salut::Service] service
  # @yieldparam [Boolean] more
  # @return [nil]
  def netServiceBrowser sender, didFindService:service, moreComing:more
    salut_service = Service.new({ service:service })
    @services << salut_service
    @delegates[__method__].call sender, salut_service, more if @delegates[__method__]
    NSLog("Found service (#{service.description})")
  end

  # @yieldparam [NSNetServiceBrowser] sender
  # @yieldparam [Salut::Service] removed_service
  # @yieldparam [Boolean] more
  # @return [nil]
  def netServiceBrowser sender, didRemoveService:service, moreComing:more
    ousted_service = nil
    @services.delete_if { |salut_service|
      if salut_service.service == service
        ousted_service = salut_service
        true
      end
    }
    @delegates[__method__].call sender, ousted_service, more if @delegates[__method__]
    NSLog("Removing service (#{service.description})")
  end

  # @yieldparam [NSNetServiceBrowser] sender
  # @return [nil]
  def netServiceBrowserWillSearch sender
    @searching = true
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Starting search (#{sender.description})")
  end

  # @yieldparam [NSNetServiceBrowser] sender
  # @yieldparam [Hash] error_dict
  # @return [nil]
  def netServiceBrowser sender, didNotSearch:error_dict
    @searching = false
    @delegates[__method__].call sender, error_dict if @delegates[__method__]
    NSLog("Failed to search (#{sender.description})\n\t problem was\n#{error_dict.description}")
  end

  # @yieldparam [NSNetServiceBrowser] sender
  # @return [nil]
  def netServiceBrowserDidStopSearch sender
    @searching = false
    @delegates[__method__].call sender if @delegates[__method__]
    NSLog("Done searching (#{sender.description})")
  end

  # @endgroup

end

end
