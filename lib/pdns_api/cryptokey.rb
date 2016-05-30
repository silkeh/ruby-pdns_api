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
  # Cryptokey for a zone.
  class CryptoKey < API
    ##
    # Creates a cryptokey object.
    #
    # - +http+:   An HTTP object for interaction with the PowerDNS server.
    # - +parent+: This object's parent.
    # - +id+:     Identifier of the cryptokey.
    # - +info+:   Optional information about the cryptokey.
    def initialize(http, parent, id, info = {})
      @class  = :cryptokeys
      @http   = http
      @parent = parent
      @id     = id
      @info   = info
      @url    = "#{parent.url}/#{@class}/#{id}"
    end

    ##
    # Changes cryptokey information
    #
    # +rrset+ is used as changeset for the update.
    def change(rrsets)
      @http.put(@url, rrsets)
    end
  end
end
