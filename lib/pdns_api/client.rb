require 'pdns_api/version'
require 'pdns_api/api'
require 'pdns_api/server'

##
#
module PDNS
  ##
  # Class for interaction with the top level API.
  class Client < API
    ##
    # The PowerDNS API version in use.
    attr_reader :version

    ##
    # Creates a client object.
    # The arguments are used to create an HTTP object,
    # which is used by all created objects.
    def initialize(args)
      @class   = :client
      @http    = PDNS::HTTP.new(args)
      @version = @http.version
      @parent  = self
      @url     = @http.uri
      @info    = {}
    end

    ##
    # Returns existing or creates server object.
    #
    # If +id+ is not set the current servers are returned in a hash
    # containing +Server+ objects.
    #
    # If +id+ is set a +Server+ object is created with the ID.
    def servers(id = nil)
      return Server.new(@http, self, id) unless id.nil?

      # Return a hash of server objects
      servers = @http.get "#{@url}/servers"
      servers.map! { |s| [s[:id], Server.new(@http, self, s[:id], s)] }.to_h
    end

    alias server servers
  end
end
