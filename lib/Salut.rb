# -*- coding: utf-8 -*-
framework 'Foundation'
require   'logger'

require   'Salut/Service'
require   'Salut/Browser'
require   'Salut/Version'

# A class to help with advertising services using Bonjour and finding
# other services that are being advertised using Bonjour.
module Salut

  class << self

    # @return [Logger]
    attr_accessor :log

  end

  @log = Logger.new STDERR

end
