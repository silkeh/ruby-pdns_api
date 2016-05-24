# PDNS Zone CryptoKeys
module PDNS
  # Zone CryptoKey
  class CryptoKey < API
    def initialize(http, t_url, id, info = {})
      @http  = http
      @id    = id
      @info  = info
      @r_url = "#{t_url}/metadata"
      @url   = "#{t_url}/metadata/#{kind}"
    end

    ## Simple interfaces to metadata

    # Change cryptokey information
    def change(rrsets)
      @http.put(@url, rrsets)
    end
  end
end
