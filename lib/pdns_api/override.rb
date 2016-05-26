##
#
module PDNS
  ##
  # Override for a server.
  class Override < API
    ##
    # The ID of the override.
    attr_reader :id

    ##
    # Creates a configuration option object.
    #
    # +http+:   An HTTP object for interaction with the PowerDNS server.
    # +parent+: This object's parent.
    # +id+:     ID of the override.
    # +info+:   Optional information of the override.
    def initialize(http, parent, id, info = {})
      @class  = :overrides
      @http   = http
      @parent = parent
      @id     = id
      @info   = info
      @url    = "#{parent.url}/#{@class}/#{id}"
    end

    ##
    # Changes override information.
    #
    # +rrset+ is used as changeset for the update.
    def change(rrsets)
      @http.put(@url, rrsets)
    end
  end
end
