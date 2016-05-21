require 'json'
require 'net/http'

# PDNS API interface
module PDNS
  require_relative 'http'

  class API
    def initialize(args)
      @@version = args.key?(:version) ? args[:version] : 1
      @@api     = PDNS::HTTP.new(args)
    end

    def hash_sym_to_string(hash)
      hash.map { |symbol, value| [symbol.to_s, value] }.to_h
    end
  end
end
