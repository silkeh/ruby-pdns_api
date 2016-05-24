require 'json'
require 'net/http'

# PDNS module
module PDNS
  require_relative 'pdns_api/client'

  class << self
    def new(args)
      Client.new(args)
    end
  end
end
