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

require 'pdns_api/http'

##
#
module PDNS
  ##
  # The superclass for all PDNS objects.
  class API
    ##
    # The url of the resource object.
    attr_reader :url

    ##
    # The class of the resource object.
    attr_reader :class

    ##
    # Changes this object's information on the server.
    #
    # +rrsets+ is used as changeset for the update.
    def change(rrsets)
      @http.put(@url, rrsets)
    end

    ##
    # Creates this object on the server
    #
    # If +info+ is set this method updates the current information.
    # The current information is used to create the object.
    def create(info = nil)
      info(info)
      @http.post("#{@parent.url}/#{@class}", @info)
    end

    ##
    # Deletes this object
    def delete
      @http.delete @url
    end

    ##
    # Gets the information of this object from the API and use it
    # to update the object's information.
    def get
      @info = @http.get @url
    end

    ##
    # Gets and sets the object information.
    # This does not cause an API request.
    #
    # If +info+ is set this method updates the current information.
    def info(info = nil)
      return @info if info.nil?

      @info.merge!(info)
    end

    ##
    # Ensures the object is an array.
    # If it is not, an array containing the item is returned.
    def ensure_array(item)
      return item if item.is_a? Array
      [item]
    end
  end
end
