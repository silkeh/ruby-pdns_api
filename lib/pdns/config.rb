# PDNS Server config
module PDNS
  # Server config
  class Config < API
    def initialize(config_setting_name, info)
      @config_setting_name = config_setting_name
      @info = info
    end

    ## Simple interfaces to metadata

    # Not yet implemented
    def get
      @@api.get "/servers/#{@server_id}/#{@config_setting_name}"
    end

    # Not yet implemented
    def change(rrsets)
      # TODO: /config/:config_setting_name: PUT
    end
  end
end
