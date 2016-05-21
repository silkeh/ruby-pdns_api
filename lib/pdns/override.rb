# PDNS Server Override
module PDNS
  require'api'

  # Server override
  class Override
    def initialize(pdns, server_id, override_id)
      @pdns          = pdns
      @server_id     = server_id
      @override_id = override_id
    end

    ## Simple interfaces to metadata

    # Not yet implemented
    def get
      # TODO: /servers/:server_id/overrides/:override_id: GET
    end

    # Not yet implemented
    def delete
      # TODO: /servers/:server_id/overrides/:override_id: DELETE
    end

    # Not yet implemented
    def change(rrsets)
      # TODO: /servers/:server_id/overrides/:override_id: PUT
    end
  end
end
