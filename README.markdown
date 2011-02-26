Salut
=====

Salut is just a little bit of example code of using Bonjour with MacRuby.

If all you want to do is log that callbacks were called back, or just add
very little to a callback, then this code will work well for you. But Apple
has already done a very good job of distilling Bonjour to the point that
even without this gem you would not have to add much code in order to use
Bonjour.

Of course, this is not a substitute for reading the [Bonjour Overview](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/NetServices/Introduction.html%23//apple_ref/doc/uid/TP40002445-SW1) and related documentation (not even close).

Reference Documentation
=======================

Apple's superb documentation of Bonjour and the Bonjour Objective-C interface:

- [Bonjour Overview](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/NetServices/Introduction.html%23//apple_ref/doc/uid/TP40002445-SW1)
- [NSNetServices Programming Guide](http://developer.apple.com/library/ios/#documentation/Networking/Conceptual/NSNetServiceProgGuide/Introduction.html)
- [NSNetService](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNetService_Class/Reference/Reference.html)
- [NSNetServiceDelegate Protocol](http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSNetServiceDelegate_Protocol/Reference/Reference.html)
- [NSNetServiceBrowser](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNetServiceBrowser_Class/Reference/Reference.html)
- [NSNetServiceBrowserDelegate Protocol](http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSNetServiceBrowserDelegate_Protocol/Reference/Reference.html)

Example Usage
=============

Advertising a hypothetical service:

            service = Salut::Service.new(
               service_type:'_http._tcp.',
              instance_name:'SalutDemo',
                       port:3000
            )
            service.start_advertising

Finding the service using the browser:

            browser = Salut::Browser.new
            # the NSNetServiceBrowserDelegate lists all the possible delegates
            # or look at the 'Delegate methods' group in lib/Salut/Browser.rb
            browser.delegate :"netServiceBrowser:didFindService:moreComing:" do
                |sender, service, more|
                service.resolve # if you want to resolve all services found
                if more
                   NSLog('Not up to date yet')
                else
                   NSLog('All caught up')
                end
            end
            browser.find_services '_http._tcp.'

If you want to stop advertising:

            service.stop_advertising

You might notice that you aren't seeing the results of the callbacks, this is because
they are waiting for the current run loop to cycle. This would happen automatically with
a GUI app, but a command line app will have to force the loop to run.

           NSRunLoop.currentRunLoop.run  # => runs indefinitely
           NSRunLoop.currentRunLoop.runUntiDate (Time.now + 5)  # => runs for 5 seconds

You can only use a Service or Browser for one thing at a time, and the API is designed
with that assumption in mind.

TODO
====

- Monitoring and TXT record stuff
- publishWithOptions default argument
- Do not pass NSNetService or NSNetServiceBrowser to callbacks

Contributing to Salut
=====================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========

Copyright (c) 2010-2011 Mark Rada. See LICENSE.txt for
further details.

