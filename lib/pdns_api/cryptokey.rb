##
#
module PDNS
  ##
  # Cryptokey for a zone.
  class CryptoKey < API

    ##
    # Creates a cryptokey object.
    #
    # +http+:   An HTTP object for interaction with the PowerDNS server.
    # +parent+: This object's parent.
    # +id+:     Identifier of the cryptokey.
    # +info+:   Optional information about the cryptokey.
    def initialize(http, parent, id, info = {})
      @class  = :cryptokeys
      @http   = http
      @parent = parent
      @id     = id
      @info   = info
      @url    = "#{parent.url}/#{@class}/#{id}"
    end

    ##
    # Changes cryptokey information
    #
    # +rrset+ is used as changeset for the update.
    def change(rrsets)
      @http.put(@url, rrsets)
    end
  end
end
