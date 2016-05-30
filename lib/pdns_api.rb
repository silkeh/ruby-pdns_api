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

require 'json'
require 'net/http'

##
# Module for interaction with the PowerDNS HTTP API.
module PDNS
  require_relative 'pdns_api/client'

  ##
  # Class for creation of PDNS objects.
  class << self
    ##
    # Create a PDNS::Client object.
    def new(args)
      Client.new(args)
    end
  end
end
