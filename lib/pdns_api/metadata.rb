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
  # Metadata for a zone.
  class Metadata < API
    ##
    # The kind of metadata.
    attr_accessor :kind

    ##
    # Creates a configuration option object.
    #
    # @param http   [HTTP]   An HTTP object for interaction with the PowerDNS server.
    # @param parent [API]    This object's parent.
    # @param kind   [String] Kind of the metadata.
    # @param value  [String] Optional value of the metadata.
    #
    def initialize(http, parent, kind, value = [])
      @class  = :metadata
      @http   = http
      @parent = parent
      @kind   = kind
      @url    = "#{parent.url}/#{@class}/#{kind}"
      @value  = get if value.empty?
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
      return @info[:metadata] if value.nil?

      # Convert to array if value is string
      value = ensure_array(value)

      # Set value and info
      @info  = { type: 'Metadata', kind: @kind, metadata: value }
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
    #   metadata = zone.metadata('ALLOW-AXFR-FROM')
    #   metadata.change('AUTO-NS')
    #
    def change(value = nil)
      value(value)
      @http.put(@url, @info)
    end
  end
end
