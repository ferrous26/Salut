Salut
=====

Salut is just a little bit of example code of using Bonjour with MacRuby.

Of course, this is not a substitute for reading the Bonjour overview (not even close).


Examples
========

Advertising a hypothetical service:

            service = Salut::Advertiser.new
            service.service_type  = '_http._tcp.'
            service.instance_name = 'My Web Service'
            service.port          = 3000
            service.start_advertising

If you want to stop advertising:

            service.stop_advertising

You might notice that you aren't seeing the results of the callbacks, this is because
they are waiting for the current run loop to cycle. This would happen automatically with
a GUI app, but a command line app will have to force the loop to run.

           NSRunLoop.currentRunLoop.run  # => runs indefinitely
           NSRunLoop.currentRunLoop.runUntiDate (Time.now + 5)  # => runs for 5 seconds


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

Copyright (c) 2010 Mark Rada. See LICENSE.txt for
further details.

