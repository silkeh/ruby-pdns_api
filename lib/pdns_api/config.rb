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

##
# Module for interaction with the PowerDNS HTTP API.
module PDNS
  ##
  # Configuration option for a DNS Server.
  class Config < API
    ##
    # @return [String] the name of the configuration option.
    attr_accessor :name

    ##
    # Disabled common methods
    undef_method :delete

    ##
    # Creates a configuration option object.
    #
    # @param http   [HTTP]   An HTTP object for interaction with the PowerDNS server.
    # @param parent [API]    This object's parent.
    # @param name   [String] Name of the configuration option.
    # @param value  [String] Optional value of the configuration option.
    #
    def initialize(http, parent, name, value = nil)
      @class  = :config
      @http   = http
      @parent = parent
      @name   = name
      @url    = "#{parent.url}/#{@class}/#{name}"
      @value  = get if value.nil?
      value(@value)
    end

    ##
    # Gets or sets the +value+ attribute.
    #
    # @param value [String, nil] the value of the object.
    # @return [String] the value of the object.
    #   If +value+ is set the object's +value+ is updated.
    #
    def value(value = nil)
      return @value if value.nil?
      @info  = { type: 'ConfigSetting', name: @name, value: value }
      @value = value
    end

    ##
    # Gets the current information.
    # This also updates +value+.
    #
    # @return [Hash] the object's information from the API.
    #
    def get
      res = @http.get @url
      value(res[:value]) if res.key? :value
      res
    end

    ##
    # Changes this object's information on the server.
    #
    # @param value [String, nil] Value to change the object to.
    #   - If +value+ is set, the current +value+ is used.
    #   - If +value+ is not set, +value+ is updated and then used.
    #
    # @return [Hash] result of the change.
    #
    # @example
    #   config = server.config('version')
    #   config.change('PowerDNS v3.14159265')
    #
    def change(value = nil)
      value(value)
      @http.put(@url, @info)
    end
  end
end
