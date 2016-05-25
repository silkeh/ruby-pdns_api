# PDNS Server config
module PDNS
  # Server config
  class Config < API
    attr_accessor :name, :value

    def initialize(http, parent, name, value = nil)
      @class  = :config
      @http   = http
      @parent = parent
      @name   = name
      @url    = "#{parent.url}/#{@class}/#{name}"
      @value  = value.get if value.nil?
      value(@value)
    end

    ## Simple interfaces to metadata
    # Get/set config value
    def value(value = nil)
      return @info[:value] if value.nil?
      @value = value
      @info  = { type: 'ConfigSetting', name: @name, value: value }
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
