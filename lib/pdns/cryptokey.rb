# PDNS Zone CryptoKeys
module PDNS
  # Zone CryptoKey
  class CryptoKey < API
    def initialize(server_id, zone_id, cryptokey_id, info = nil)
      @server_id     = server_id
      @zone_id       = zone_id
      @cryptokey_id  = cryptokey_id
      @info          = nil
    end

    ## Simple interfaces to metadata

    # Not yet implemented
    def get
      # TODO: /servers/:server_id/zones/:zone_name/cryptokeys/:cryptokey_id: GET
    end

    # Not yet implemented
    def delete
      # TODO: /servers/:server_id/zones/:zone_name/cryptokeys/:cryptokey_id: DELETE
    end

    # Not yet implemented
    def change(rrsets)
      # TODO: /servers/:server_id/zones/:zone_name/cryptokeys/:cryptokey_id: PUT
    end
  end
end
