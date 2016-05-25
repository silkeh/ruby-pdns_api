##
#
module PDNS
  ##
  # Configuration option for a DNS Server.
  class Config < API
    ##
    # Name of the configuration option.
    attr_accessor :name

    ##
    # Value of the configuration option.
    attr_accessor :value

    ##
    # Create a configuration option object.
    #
    # +http+:   An HTTP object for interaction with the PowerDNS server.
    # +parent+: This object's parent.
    # +name+:   Name of the configuration option.
    # +value+:  Optional value of the configuration option.
    def initialize(http, parent, name, value = nil)
      @class  = :config
      @http   = http
      @parent = parent
      @name   = name
      @url    = "#{parent.url}/#{@class}/#{name}"
      @value  = value.get if value.nil?
      value(@value)
    end

    ##
    # Get or set the +value+ attribute.
    #
    # If +value+ is not set the current +value+ is returned.
    # If +value+ is set the object's +value+ is updated and +info+ is set and returned
    def value(value = nil)
      return @value if value.nil?
      @value = value
      @info  = { type: 'ConfigSetting', name: @name, value: value }
    end

    ##
    # Get the current information.
    # This also updates +value+.
    def get
      res = @http.get(@url)
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
