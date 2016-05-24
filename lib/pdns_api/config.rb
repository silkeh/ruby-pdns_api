# PDNS Server config
module PDNS
  # Server config
  class Config < API
    attr_accessor :name, :value

    def initialize(http, t_url, name, value = nil)
      @http  = http
      @name  = name
      @r_url = "#{t_url}/config"
      @url   = "#{t_url}/config/#{name}"
      @value = value.get if value.nil?
      value(value)
    end

    ## Simple interfaces to metadata
    # Get/set config value
    def value(value = nil)
      return @info[:value] if value.nil?
      @info = { type: 'ConfigSetting', namen: @name, value: value }
    end

    # Get configuration value
    def get
      res = @http.get(@url)
      return value if res.key? :value
    end

    # Change configuration
    def change(value = nil)
      value(value)
      @http.put(@url, @info)
    end
  end
end
