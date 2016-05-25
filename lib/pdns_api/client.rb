require 'pdns_api/version'
require 'pdns_api/api'
require 'pdns_api/server'

# PDNS client
module PDNS
  # Client
  class Client < API
    attr_reader :version

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

    ## Main methods
    def servers(id = nil)
      return Server.new(@http, self, id) unless id.nil?

      # Return a hash of server objects
      servers = @http.get "#{@url}/servers"
      servers.map! { |s| [s[:id], Server.new(@http, self, s[:id], s)] }.to_h
    end

    alias server servers
  end
end
