# PDNS Zone Metadata
module PDNS
  # Zone Metadata
  class Metadata < API
    def initialize(http, parent, kind, info = {})
      @class  = :metadata
      @http   = http
      @parent = parent
      @kind   = kind
      @info   = info
      @url    = "#{parent.url}/metadata/#{kind}"
    end

    ## Simple interfaces to metadata

    # Set the metadata value
    def value(value = nil)
      return @info[:metadata] if value.nil?

      # Convert to array if value is string
      value = [value] if value.is_a? String

      # Set info
      @info = { type: 'Metadata', kind: @kind, metadata: value }
    end

    # Retrieve metadata value
    def get
      res = @http.get @url
      return value if res.key? :value
    end

    # Change metadata
    def change(value)
      value(value)
      @http.put(@url, @info)
    end
  end
end
