# PDNS Zone CryptoKeys
module PDNS
  # Zone CryptoKey
  class CryptoKey < API
    def initialize(http, parent, id, info = {})
      @class  = :cryptokeys
      @http   = http
      @parent = parent
      @id     = id
      @info   = info
      @url    = "#{parent.url}/#{@class}/#{id}"
    end

    ## Simple interfaces to metadata

    # Change cryptokey information
    def change(rrsets)
      @http.put(@url, rrsets)
    end
  end
end
