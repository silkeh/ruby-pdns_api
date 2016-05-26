require 'json'
require 'net/http'

##
# Module for interaction with the PowerDNS HTTP API.
module PDNS
  require_relative 'pdns_api/client'

  ##
  # Class for creation of PDNS objects.
  class << self

    ##
    # Create a PDNS::Client object.
    def new(args)
      Client.new(args)
    end
  end
end
