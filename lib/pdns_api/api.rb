require 'pdns_api/http'

##
# Module for interaction with the PowerDNS HTTP API.

module PDNS

  ##
  # The superclass for all PDNS objects.

  class API

    attr_reader :url, :class, :version

    ##
    # Creates a client object.
    # The arguments are used to create an HTTP object,
    # which is used by all created objects

    def initialize(args)
      @class   = :client
      @http    = PDNS::HTTP.new(args)
      @version = @http.version
      @parent  = self
      @url     = @http.uri
      @info    = {}
    end

    ## Standard manipulation methods

    ##
    # Get the information of this object from the API
    def get
      @info = @http.get @url
    end

    ##
    # Deletes this object

    def delete
      @http.delete @url
    end

    ##
    # Creates this object on the server

    def create(info = nil)
      info(info)
      @http.post("#{@parent.url}/#{@class}", @info)
    end

    ##
    # Get and set the object information.
    # This does not cause an API request.
    #
    # If +info+ is set this method updates the current information.
    #

    def info(info = nil)
      return @info if info.nil?

      @info.merge!(info)
    end

    ## Helper methods

    ##
    # Ensure the object is an array.
    # If it is not, an array containing the item is returned

    def ensure_array(item)
      return item if item.is_a? Array
      [item]
    end

    def self.hash_sym_to_string(hash)
      hash.map { |symbol, value| [symbol.to_s, value] }.to_h
    end

    def self.hash_string_to_sym(hash)
      hash.map { |string, value| [string.to_sym, value] }.to_h
    end
  end
end
