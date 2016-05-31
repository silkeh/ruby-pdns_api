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
#
module PDNS
  ##
  # Configuration option for a DNS Server.
  class Config < API
    ##
    # The name of the configuration option.
    attr_accessor :name

    ##
    # The value of the configuration option.
    attr_accessor :value

    ##
    # Disabled common methods
    undef_method :delete

    ##
    # Creates a configuration option object.
    #
    # - +http+:   An HTTP object for interaction with the PowerDNS server.
    # - +parent+: This object's parent.
    # - +name+:   Name of the configuration option.
    # - +value+:  Optional value of the configuration option.
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
    # If +value+ is not set the current +value+ is returned.
    # If +value+ is set the object's +value+ is updated and +info+ is set and returned
    def value(value = nil)
      return @value if value.nil?
      @value = value
      @info  = { type: 'ConfigSetting', name: @name, value: value }
    end

    ##
    # Gets the current information.
    # This also updates +value+.
    def get
      res = @http.get @url
      value(res[:value]) if res.key? :value
      res
    end

    ##
    # Updates the object on the server.
    #
    # If +value+ is set, the current +value+ is used.
    # If +value+ is not set, +value+ is updated and then used.
    def change(value = nil)
      value(value)
      @http.put(@url, @info)
    end
  end
end
