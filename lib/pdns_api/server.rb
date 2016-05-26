require 'pdns_api/config'
require 'pdns_api/override'
require 'pdns_api/zone'

##
#
module PDNS
  ##
  # Server object for accessing data for a particular server.
  class Server < API
    ##
    # The ID of the server.
    attr_reader :id

    ##
    # Creates a Server object.
    #
    # +http+:   An HTTP object for interaction with the PowerDNS server.
    # +parent+: This object's parent.
    # +id+:     ID of the server.
    # +info+:   Optional information of the server.
    def initialize(http, parent, id, info = {})
      @class  = :servers
      @http   = http
      @parent = parent
      @id     = id
      @url    = "#{parent.url}/#{@class}/#{id}"
      @info   = info
    end

    ##
    # Flushes cache for +domain+.
    def cache(domain)
      # TODO: #{url}/cache/flush?domain=:domain: PUT
    end

    ##
    # Searches through the server's log with +search_term+.
    def search_log(search_term)
      # TODO: /servers/:server_id/search-log?q=:search_term: GET
    end

    ##
    # Gets the statistics for the server.
    def statistics
      # TODO: /servers/:server_id/statistics: GET
    end

    ##
    # Manipulates the query tracing log.
    def trace
      # TODO: /servers/:server_id/trace: GET, PUT
    end

    ##
    # Manipulates failure logging.
    def failures
      # TODO: /servers/:server_id/failures: GET, PUT
    end

    ##
    # Returns existing configuration or creates a +Config+ object.
    #
    # If +name+ is not set the current configuration is returned in a hash.
    #
    # If +name+ is set a +Config+ object is returned using the provided +name+.
    # If +value+ is set as well, a complete config object is returned.
    def config(name = nil, value = nil)
      return Config.new(@http, self, name, value) unless name.nil? || value.nil?
      return Config.new(@http, self, name) unless name.nil?

      # Get all current configuration
      config = @http.get("#{@url}/config")
      config.map { |c| [c[:name], c[:value]] }.to_h
    end

    ##
    # Returns existing or creates an +Override+ object.
    #
    # If +id+ is not set the current servers are returned in a hash
    # containing +Override+ objects.
    #
    # If +id+ is set an +Override+ object with the provided ID is returned.
    def overrides(id = nil)
      return Override.new(@http, self, id) unless id.nil?

      overrides = @http.get("#{@url}/config")
      overrides.map { |o| [o[:id], Override.new(@http, self, o[:id], o)] }.to_h
    end

    ##
    # Returns existing or creates a +Zone+ object.
    #
    # If +id+ is not set the current servers are returned in a hash
    # containing +Zone+ objects.
    #
    # If +id+ is set a +Server+ object with the provided ID is returned.
    def zones(id = nil)
      return Zone.new(@http, self, id) unless id.nil?

      zones = @http.get("#{@url}/zones")
      zones.map { |z| [z[:id], Zone.new(@http, self, z[:id], z)] }.to_h
    end

    alias override overrides
    alias zone zones
  end
end
