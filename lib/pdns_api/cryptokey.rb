# PDNS Zone CryptoKeys
module PDNS
  # Zone CryptoKey
  class CryptoKey < API
    def initialize(t_url, id, info = {})
      @id    = id
      @info  = info
      @r_url = "#{t_url}/metadata"
      @url   = "#{t_url}/metadata/#{kind}"
    end

    ## Simple interfaces to metadata

    # Change cryptokey information
    def change(rrsets)
      @@api.put(@url, rrsets)
    end
  end
end
