# PDNS Server Override
module PDNS
  # Server override
  class Override < API
    attr_reader :id, :url, :info

    def initialize(http, parent, id, info = {})
      @class  = :overrides
      @http   = http
      @parent = parent
      @id     = id
      @info   = info
      @url    = "#{parent.url}/#{@class}/#{id}"
    end

    ## Simple interfaces to overrides

    # Change override settings
    def change(rrsets)
      @http.put(@url, rrsets)
    end
  end
end
