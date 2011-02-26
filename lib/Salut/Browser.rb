require 'Salut/Service'

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

    # @return [Array<Salut::Service>]
    attr_reader :services

    # @return [NSNetServiceBrowser]
    attr_reader :browser

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

    # A shortcut for reading/writing to the delegate methods hash
    # @param [Symbol] method the name of the callback
    # @return [Proc]
    def delegate method
      if block_given?
        @delegates[method] = Proc.new
      else
        @delegates[method]
      end
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

    # @todo find a way to use default arguments
    # @param [String] service_name
    # @param [String] domain_name
    def find_services service_type, domain_name = ''
      @browser.searchForServicesOfType service_type, inDomain:domain_name
    end

    alias_method :stop_finding_services, :stop_finding

    # @endgroup


    # @group Delegate methods

    # @yieldparam [Salut::Browser] sender
    # @yieldparam [String] domain_name
    # @yieldparam [Boolean] more
    # @return [nil]
    def netServiceBrowser sender, didFindDomain:domain_name, moreComing:more
      @domains << domain_name
      @delegates[__method__].call self, domain_name, more if @delegates[__method__]
      Salut.log.info "Found domain: #{domain_name}"
    end

    # @yieldparam [Salut::Browser] sender
    # @yieldparam [String] domain_name
    # @yieldparam [Boolean] more
    # @return [nil]
    def netServiceBrowser sender, didRemoveDomain:domain_name, moreComing:more
      @domains.delete domain_name
      @delegates[__method__].call self, domain_name, more if @delegates[__method__]
      Salut.log.info "Removing domain: #{domain_name}"
    end

    # @yieldparam [Salut::Browser] sender
    # @yieldparam [Salut::Service] service
    # @yieldparam [Boolean] more
    # @return [nil]
    def netServiceBrowser sender, didFindService:service, moreComing:more
      salut_service = Service.new service:service
      @services << salut_service
      @delegates[__method__].call self, salut_service, more if @delegates[__method__]
      Salut.log.info "Found service (#{service.description})"
    end

    # @yieldparam [Salut::Browser] sender
    # @yieldparam [Salut::Service] removed_service
    # @yieldparam [Boolean] more
    # @return [nil]
    def netServiceBrowser sender, didRemoveService:service, moreComing:more
      removed_service = nil
      @services.delete_if { |salut_service|
        if salut_service.service == service
          removed_service = salut_service
          true
        end
      }
      @delegates[__method__].call self, removed_service, more if @delegates[__method__]
      Salut.log.info "Removing service (#{service.description})"
    end

    # @yieldparam [Salut::Browser] sender
    # @return [nil]
    def netServiceBrowserWillSearch sender
      @searching = true
      @delegates[__method__].call self if @delegates[__method__]
      Salut.log.info "Starting search (#{sender.description})"
    end

    # @yieldparam [Salut::Browser] sender
    # @yieldparam [Hash] error_dict
    # @return [nil]
    def netServiceBrowser sender, didNotSearch:error_dict
      @searching = false
      @delegates[__method__].call self, error_dict if @delegates[__method__]
      Salut.log.info "Failed to search (#{sender.description})\n\t problem was\n#{error_dict.description}"
    end

    # @yieldparam [Salut::Browser] sender
    # @return [nil]
    def netServiceBrowserDidStopSearch sender
      @searching = false
      @delegates[__method__].call self if @delegates[__method__]
      Salut.log.info "Done searching (#{sender.description})"
    end

    # @endgroup

  end

end
