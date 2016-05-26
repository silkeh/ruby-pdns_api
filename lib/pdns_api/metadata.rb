##
#
module PDNS
  ##
  # Metadata for a zone.
  class Metadata < API
    ##
    # The kind of metadata.
    attr_accessor :kind

    ##
    # The value of the metadata.
    attr_accessor :value

    ##
    # Creates a configuration option object.
    #
    # - +http+:   An HTTP object for interaction with the PowerDNS server.
    # - +parent+: This object's parent.
    # - +kind+:   Name of the metadata.
    # - +value+:  Optional value of the metadata.
    def initialize(http, parent, kind, value = [])
      @class  = :metadata
      @http   = http
      @parent = parent
      @kind   = kind
      @url    = "#{parent.url}/#{@class}/#{kind}"
      @value  = value.get if value.empty?
      value(@value)
    end

    ##
    # Gets or sets the +value+ attribute.
    #
    # If +value+ is not set the current +value+ is returned.
    # If +value+ is set the object's +value+ is updated and +info+ is set and returned.
    def value(value = nil)
      return @info[:metadata] if value.nil?

      # Convert to array if value is string
      value = ensure_array(value)

      # Set value and info
      @value = value
      @info  = { type: 'Metadata', kind: @kind, metadata: value }
    end

    ##
    # Gets the current information.
    # This also updates +value+.
    def get
      res = @http.get @url
      value(res[:value]) if res.key? :value
      res
    end

    ##
    # Updates the object on the server.
    #
    # If +value+ is set, the current +value+ is used.
    # If +value+ is not set, +value+ is updated and then used.
    def change(value = nil)
      value(value)
      @http.put(@url, @info)
    end
  end
end
