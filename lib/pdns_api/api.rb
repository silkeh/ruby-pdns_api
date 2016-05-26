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
    # Gets the information of this object from the API and use it
    # to update the object's information.
    def get
      @info = @http.get @url
    end

    ##
    # Deletes this object
    def delete
      @http.delete @url
    end

    ##
    # Creates this object on the server
    def create(info = nil)
      info(info)
      @http.post("#{@parent.url}/#{@class}", @info)
    end

    ##
    # Gets and sets the object information.
    # This does not cause an API request.
    #
    # If +info+ is set this method updates the current information.
    #
    def info(info = nil)
      return @info if info.nil?

      @info.merge!(info)
    end

    ##
    # Ensures the object is an array.
    # If it is not, an array containing the item is returned
    def ensure_array(item)
      return item if item.is_a? Array
      [item]
    end
  end
end
