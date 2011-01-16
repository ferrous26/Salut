# -*- coding: utf-8 -*-
framework 'Foundation'

module Salut

  # Browsers are used for searching for services or domains. A single instance
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
      @searching        = false
    end

    # Stop searching for things, whether they be domains or services
    def stop_finding
      @browser.stop
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


    # @group Finding domains

    # @return [nil]
    def find_browsable_domains
      @browser.searchForBrowsableDomains
    end

    alias_method :stop_finding_domains, :stop_finding

    # @endgroup


    # @group Finding services

    # @param [String] service_name
    # @param [String] domain_name
    def find_services service_type, in_domain:domain_name
      @browser.searchForServicesOfType service_type, inDomain:domain_name
    end

    alias_method :stop_finding_services, :stop_finding

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
      removed_service
      @services.delete_if { |salut_service|
        if salut_service.service == service
          removed_service = salut_service
          true
        end
      }
      @delegates[__method__].call sender, removed_service, more if @delegates[__method__]
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
