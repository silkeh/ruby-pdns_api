# PDNS client
module PDNS
  require_relative 'api'
  require_relative 'server'

  # Client
  class Client < API
    attr_reader :version

    ## Main methods
    def servers(server_id = nil)
      return Server.new(server_id) unless server_id.nil?

      # Return a hash of server objects
      servers = @@api.get('/servers')
      servers.map! do |info|
        id = info['id']
        [id, Server.new(id, info)]
      end
      servers.to_h

      # TODO: /servers: PUT, POST, DELETE
    end

    alias server servers
  end
end
