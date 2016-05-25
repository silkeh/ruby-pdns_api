require 'json'
require 'net/http'

##
# Module for interaction with the PowerDNS HTTP API.
module PDNS
  require_relative 'pdns_api/client'

  class << self
    def new(args)
      Client.new(args)
    end
  end
end
