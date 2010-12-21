# -*- coding: utf-8 -*-
framework 'Foundation'

module Salut

# Advertises its service on the local network using Bonjour.
class Advertiser

  # @return [String] service_type
  attr_accessor :service_type

  # @return [String] instance_name
  attr_accessor :instance_name

  # @return [Fixnum] port
  attr_accessor :port

  # Create a new NSNetService instance and publish to the local network.
  # @return [NSNetService] the service that began advertising
  def start_advertising
    @service = NSNetService.alloc.initWithDomain '',
                                            type:@service_type,
                                            name:@instance_name,
                                            port:@port
    @service.delegate = self
    @service.scheduleInRunLoop NSRunLoop.currentRunLoop, forMode:NSDefaultRunLoopMode
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
    NSLog("Starting to advertise service (#{sender.description})")
  end

  # @param [Hash] error_dict
  # @return [nil]
  def netService sender, didNotPublish:error_dict
    NSLog("ERROR: could not advertise service (#{sender.description})\n\t the problem was\n#{error_dict.description}")
  end

  # @return [nil]
  def netServiceDidPublish sender
    NSLog("Successfully advertising service (#{sender.description})")
  end

  # @return [nil]
  def netServiceWillResolve sender
    NSLog("Resolving service (#{sender.description})")
  end

  # @param [Hash] error_dict
  # @return [nil]
  def netService sender, didNotResolve:error_dict
    NSLog("ERROR: could not resolve service (#{sender.description})\n\t the problem was\n#{error_dict.description}")
  end

  # @return [nil]
  def netServiceDidResolveAddress sender
    NSLog("Resolved address for service (#{sender.description})")
  end

  # @param [NSData] data the new TXT record
  # @return [nil]
  def netService sender, didUpdateTXTRecordData:data
    NSLog("Updated TXT record for service (#{sender.description})")
  end

  # @return [nil]
  def netServiceDidStop sender
    NSLog("Stopped advertising service (#{sender.description})")
  end
end

# Browses the local network for other MCTestHarness instances and
# maintains a list of all the services it finds. Uses Bonjour to
# do the heavy lifting.
class Browser

  def initialize
    @browser = NSNetServiceBrowser.new
    @browser.scheduleInRunLoop NSRunLoop.currentRunLoop, forMode:NSDefaultRunLoopMode
    @browser.delegate = self
  end

  def populate_browsable_domains
    @browser.searchForBrowsableDomains
  end

  # @param [String] service_name
  # @param [String] domain_name
  def find_service service_name, in_domain:domain_name
    @browser.searchForServiceOfType service_name, inDomain:domain_name
  end

  ### delegates

  # @return [nil]
  def netServiceBrowser sender, didFindDomain:domain_name, moreComing:more
    NSLog("Found domain: #{domain_name}")
  end

  # @return [nil]
  def netServiceBrowser sender, didRemoveDomain:domain_name, moreComing:more
    NSLog("Removing domain: #{domain_name}")
  end

  # @return [nil]
  def netServiceBrowser sender, didFindService:service, moreComing:more
    NSLog("Found service (#{service.description})")
  end

  # @return [nil]
  def netServiceBrowser sender, didRemoveService:service, moreComing:more
    NSLog("Removing service (#{service.description})")
  end

  # @return [nil]
  def netServiceBrowserWillSearch sender
    NSLog("Starting search (#{sender.description})")
  end

  # @return [nil]
  def netServiceBrowser sender, didNotSearch:error_dict
    NSLog("Failed to search (#{sender.description})\n\t problem was\n#{error_dict.description}")
  end

  # @return [nil]
  def netServiceBrowserDidStopSearch sender
    NSLog("Done searching (#{sender.description})")
  end
end

end
