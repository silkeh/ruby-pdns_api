# PDNS module
module PDNS
  require_relative 'pdns/client'

  class << self
    def new(args)
      Client.new(args)
    end
  end
end
