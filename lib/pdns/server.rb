# PDNS Server
module PDNS
  # PDNS Server
  class Server < API
    require_relative 'zone'

    attr_reader :info

    def initialize(server_id, info = nil)
      @server_id = server_id
      @info      = info
    end

    ## Server interfaces
    # TODO: /servers/:server_id: ?

    # Get server information
    def get
      @@api.get "/servers/#{@server_id}"
    end

    ## Server actions

    def cache(domain)
      # TODO: /servers/:server_id/cache/flush?domain=:domain: PUT
    end

    def search_log(search_term)
      # TODO: /servers/:server_id/search-log?q=:search_term: GET
    end

    def statistics
      # TODO: /servers/:server_id/statistics: GET
    end

    def trace
      # TODO: /servers/:server_id/trace: GET, PUT
    end

    def failures
      # TODO: /servers/:server_id/failures: GET, PUT
    end

    ## Server resources

    # Get or set server config
    def config(config_setting_name = nil, _data = nil)
      return Config.new(@server_id, config_setting_name) unless config_setting_name.nil?

      # TODO: /config: GET, POST
    end

    # Get or set server overrides
    def overrides(override_id = nil)
      return Override.new(@server_id, override_id) unless override_id.nil?

      # TODO: /servers/:server_id/overrides: GET, POST
    end

    # Get zones or create one
    def zones(zone_id = nil)
      return Zone.new(@server_id, zone_id) unless zone_id.nil?

      zones = @@api.get("/servers/#{@server_id}/zones")
      zones.map! do |zone|
        [
          zone['id'],
          Zone.new(@server_id, zone['id'], zone)
        ]
      end
      zones.to_h

      # TODO: /servers/:server_id/zones: POST
    end

    alias zone zones
  end
end
