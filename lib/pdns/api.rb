require 'json'
require 'net/http'

# PDNS API interface
module PDNS
  require_relative 'http'

  # Class for interacting with the API
  class API
    def initialize(args)
      @@version = args.key?(:version) ? args[:version] : 1
      @@api     = PDNS::HTTP.new(args)
      @url      = @@api.uri
      @r_url    = @url
      @info     = {}
    end

    ## Standard manipulation methods

    # Get information for this object
    def get
      @info = @@api.get @url
    end

    # Delete this object
    def delete
      @@api.delete @url
    end

    # Create this object on the server
    def create(info = nil)
      info(info)
      @@api.post(@r_url, @info)
    end

    # Get/set info
    def info(info = nil)
      return @info if info.nil?

      @info.merge!(hash_sym_to_string(info))
    end

    ## Helper methods

    def hash_sym_to_string(hash)
      hash.map { |symbol, value| [symbol.to_s, value] }.to_h
    end

    def hash_string_to_sym(hash)
      hash.map { |string, value| [string.to_sym, value] }.to_h
    end
  end
end
