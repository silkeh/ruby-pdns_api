require 'pdns_api/http'

# PDNS API interface
module PDNS
  # Class for interacting with the API
  class API
    def initialize(args)
      @version = args.key?(:version) ? args[:version] : 1
      @http    = PDNS::HTTP.new(args)
      @url     = @http.uri
      @r_url   = @url
      @info    = {}
    end

    ## Standard manipulation methods

    # Get information for this object
    def get
      @info = @http.get @url
    end

    # Delete this object
    def delete
      @http.delete @url
    end

    # Create this object on the server
    def create(info = nil)
      info(info)
      @http.post(@r_url, @info)
    end

    # Get/set info
    def info(info = nil)
      return @info if info.nil?

      @info.merge!(info)
    end

    ## Helper methods

    def ensure_array(item)
      return item if item.is_a? Array
      [item]
    end

    def self.hash_sym_to_string(hash)
      hash.map { |symbol, value| [symbol.to_s, value] }.to_h
    end

    def self.hash_string_to_sym(hash)
      hash.map { |string, value| [string.to_sym, value] }.to_h
    end
  end
end
