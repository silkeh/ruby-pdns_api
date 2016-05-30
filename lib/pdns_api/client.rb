# Copyright 2016 - Silke Hofstra
#
# Licensed under the EUPL, Version 1.1 or -- as soon they will be approved by
# the European Commission -- subsequent versions of the EUPL (the "Licence");
# You may not use this work except in compliance with the Licence.
# You may obtain a copy of the Licence at:
#
# https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" basis,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied.
# See the Licence for the specific language governing
# permissions and limitations under the Licence.
#

require 'pdns_api/version'
require 'pdns_api/api'
require 'pdns_api/server'

##
#
module PDNS
  ##
  # Class for interaction with the top level API.
  class Client < API
    ##
    # The PowerDNS API version in use.
    attr_reader :version

    ##
    # Creates a client object.
    # +args+ is used to create an HTTP object,
    # which is used by all created objects.
    def initialize(args)
      @class   = :client
      @http    = PDNS::HTTP.new(args)
      @version = @http.version
      @parent  = self
      @url     = @http.uri
      @info    = {}
    end

    ##
    # Returns existing or creates a +Server+ object.
    #
    # If +id+ is not set the current servers are returned in a hash
    # containing +Server+ objects.
    #
    # If +id+ is set a +Server+ object with the provided ID is returned.
    def servers(id = nil)
      return Server.new(@http, self, id) unless id.nil?

      # Return a hash of server objects
      servers = @http.get "#{@url}/servers"
      servers.map! { |s| [s[:id], Server.new(@http, self, s[:id], s)] }.to_h
    end

    alias server servers
  end
end
