require 'pdns_api/version'
require 'pdns_api/api'
require 'pdns_api/server'

# PDNS client
module PDNS
  # Client
  class Client < API
    attr_reader :version

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
