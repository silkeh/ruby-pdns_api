require 'json'
require 'net/http'

# PDNS HTTP API interface
module PDNS
  # Class for doing HTTP requests
  class HTTP
    attr_accessor :headers

    def initialize(args)
      @host    = args[:host]
      @key     = args[:key]
      @port    = args.key?(:port)    ? args[:port]    : 8081
      @version = args.key?(:version) ? args[:version] : 1
      @headers = { 'X-API-Key' => @key }
    end

    def uri(request)
      base = @version == 0 ? '' : "/api/v#{@version}"
      base + request
    end

    # Do an HTTP request
    def http(method, request, body = nil)
      # Start an HTTP connection
      begin
        response = Net::HTTP.start(@host, @port) do |http|
          # Create uri
          uri = uri(request)

          # Create the right request
          req = case method
                when 'GET'    then Net::HTTP::Get.new(uri, @headers)
                when 'PATCH'  then Net::HTTP::Patch.new(uri, @headers)
                when 'POST'   then Net::HTTP::Post.new(uri, @headers)
                when 'PUT'    then Net::HTTP::Put.new(uri, @headers)
                when 'DELETE' then Net::HTTP::Delete.new(uri, @headers)
                else               abort('Unknown method: ' + method)
                end

          # Do the request
          http.request(req, body.to_json)
        end
      rescue EOFError
        abort('Error: could not connect to server - connection refused')
      rescue Exception => e
        abort("Error: #{e}")
      end

      # Parse and return JSON
      begin
        JSON.parse response.body
      rescue JSON::ParserError
        abort("Non-JSON response: #{response.body}")
      end
    end

    # Do a DELETE request
    def delete(uri)
      http('DELETE', uri)
    end

    # Do a GET request
    def get(uri)
      http('GET', uri)
    end

    # Do a PATCH request
    def patch(uri, body = nil)
      http('PATCH', uri, body)
    end

    # Do a POST request
    def post(uri, body = nil)
      http('POST', uri, body)
    end

    # Do a PUT request
    def put(uri, body = nil)
      http('PUT', uri, body)
    end
  end
end
