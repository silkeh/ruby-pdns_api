# PDNS Server Override
module PDNS
  # Server override
  class Override < API
    attr_reader :id, :url, :info

    def initialize(t_url, id, info = {})
      @id    = id
      @info  = info
      @r_url = "#{t_url}/metadata"
      @url   = "#{t_url}/metadata/#{kind}"
    end

    ## Simple interfaces to overrides

    # Change override settings
    def change(rrsets)
      @@api.put(@url, rrsets)
    end
  end
end
