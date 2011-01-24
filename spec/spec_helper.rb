require 'rubygems'
require 'mac_bacon'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'Salut'

# A macro for forcing the run loop to run. This is a blocking
# operation.
# @param [Fixnum] time number of seconds to run the current run loop
def run_run_loop time = 2
  NSRunLoop.currentRunLoop.runUntilDate (Time.now + time)
end
