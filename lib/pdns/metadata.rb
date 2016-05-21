# PDNS Zone Metadata
module PDNS
  # Zone Metadata
  class Metadata < API
    def initialize(t_url, kind, info = {})
      @kind  = kind
      @info  = info
      @r_url = "#{t_url}/metadata"
      @url   = "#{t_url}/metadata/#{kind}"
    end

    ## Simple interfaces to metadata

    # Set the metadata value
    def value(value = nil)
      return @info['metadata'] if value.nil?

      # Convert to array if value is string
      value = [value] if value.is_a? String

      # Set info
      @info = { 'type' => 'Metadata', 'kind' => @kind, 'metadata' => value }
    end

    # Retrieve metadata value
    def get
      res = @@api.get @url
      return value if res.key? 'value'
    end

    # Change metadata
    def change(value)
      value(value)
      @@api.put(@url, @info)
    end
  end
end
