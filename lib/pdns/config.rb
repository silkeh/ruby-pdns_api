# PDNS Server config
module PDNS
  # Server config
  class Config < API
    attr_accessor :name, :value

    def initialize(t_url, name, value = nil)
      @name  = name
      @r_url = "#{t_url}/config"
      @url   = "#{t_url}/config/#{name}"
      @value = value.get if value.nil?
      value(value)
    end

    ## Simple interfaces to metadata
    # Get/set config value
    def value(value = nil)
      return @info['value'] if value.nil?
      @info = { 'type' => 'ConfigSetting', 'name' => @name, 'value' => value }
    end

    # Get configuration value
    def get
      res = @@api.get(@url)
      return value if res.key? 'value'
    end

    # Change configuration
    def change(value = nil)
      value(value)
      @@api.put(@url, @info)
    end
  end
end
