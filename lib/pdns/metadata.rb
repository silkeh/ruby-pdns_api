# PDNS Zone Metadata
module PDNS
  # Zone Metadata
  class Metadata < API
    def initialize(server_id, zone_id, metadata_kind, info = nil)
      @server_id     = server_id
      @zone_id       = zone_id
      @metadata_kind = metadata_kind
      @info          = info
    end

    ## Simple interfaces to metadata

    # Not yet implemented
    def get
      # TODO: /servers/:server_id/zones/:zone_name/metadata/:metadata_kind: GET
    end

    # Not yet implemented
    def delete
      # TODO: /servers/:server_id/zones/:zone_name/metadata/:metadata_kind: DELETE
    end

    # Not yet implemented
    def change(rrsets)
      # TODO: /servers/:server_id/zones/:zone_name/metadata/:metadata_kind: PUT
    end
  end
end
