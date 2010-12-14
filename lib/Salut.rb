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
    @service.publish
  end

  # @return [NSNetService] the service that just stopped advertising
  def stop_advertising
    @service.stop
    @service = nil
  end


  ### delegate methods

  # @return [nil]
  def netServiceWillPublish sender
    NSLog("Starting to advertise service #{sender.description}")
  end

  # @param [Hash] error_dict
  # @return [nil]
  def netService sender, didNotPublish:error_dict
    NSLog("ERROR: could not advertise service #{sender.description}\n\t the problem was\n #{error_dict.description}")
  end

  # @return [nil]
  def netServiceDidPublish sender
    NSLog("Successfully advertising service #{sender.description}")
  end

  # @return [nil]
  def netServiceWillResolve sender
    NSLog("Resolving service: #{sender.description}")
  end

  # @param [Hash] error_dict
  # @return [nil]
  def netService sender, didNotResolve:error_dict
    NSLog("ERROR: could not resolve service #{sender.description}\n\t the problem was\n #{error_dict.description}")
  end

  # @return [nil]
  def netServiceDidResolveAddress sender
    NSLog("Resolved address for service #{sender.description}")
  end

  # @param [NSData] data the new TXT record
  # @return [nil]
  def netService sender, didUpdateTXTRecordData:data
    NSLog("Updated TXT record for service #{sender.description}")
  end

  # @return [nil]
  def netServiceDidStop sender
    NSLog("Stopping the advertisement for service #{sender.description}")
  end

  # @return [nil]
  def netServiceDidStop sender
    NSLog("Stopped advertising service #{sender.description}")
  end
end

end
