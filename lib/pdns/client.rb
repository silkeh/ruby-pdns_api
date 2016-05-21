# PDNS client
module PDNS
  require_relative 'api'
  require_relative 'server'

  # Client
  class Client < API
    attr_reader :version

    ## Main methods
    def servers(id = nil)
      return Server.new(@url, id) unless id.nil?

      # Return a hash of server objects
      servers = @@api.get "#{@url}/servers"
      servers.map! { |s| [s['id'], Server.new(@url, s['id'], s)] }.to_h
    end

    alias server servers
  end
end
