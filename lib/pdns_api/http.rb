##
#
module PDNS
  ##
  # Class for connecting to the PowerDNS API.
  class HTTP
    ##
    # Headers used for requests
    attr_accessor :headers

    ##
    # The PowerDNS API version in use.
    attr_reader   :version

    ##
    # Creates a PDNS connection.
    #
    # +args+ is a a hash which should include:
    # - +:host+: hostname or IP address of the PowerDNS server.
    # - +:key+:  API key for the PowerDNS server.
    #
    # It may include:
    # - +:port+:    Port the server listens on. Defaults to +8081+.
    # - +:version+: Version of the API to use.  Defaults to +1+.
    #   The version of the API depends on the version of PowerDNS.
    #
    # TODO: retrieve endpoint from +/api+ if version is not provided.
    def initialize(args)
      @host    = args[:host]
      @key     = args[:key]
      @port    = args.key?(:port)    ? args[:port]    : 8081
      @version = args.key?(:version) ? args[:version] : 1
      @headers = { 'X-API-Key' => @key }
    end

    ##
    # Returns the correct URI for a request.
    # This depends on the API version.
    def uri(request = '')
      base = ''
      base = "/api/v#{@version}" unless @version == 0 || request[0..3] == '/api'
      base + request
    end

    ##
    # Returns the correct Net:HTTP object for the request.
    def http_method(method, uri)
      # Debug output
      puts "#{method}: #{uri}" if ENV['DEBUG']

      # Create the right request
      case method
      when 'GET'    then Net::HTTP::Get.new(uri, @headers)
      when 'PATCH'  then Net::HTTP::Patch.new(uri, @headers)
      when 'POST'   then Net::HTTP::Post.new(uri, @headers)
      when 'PUT'    then Net::HTTP::Put.new(uri, @headers)
      when 'DELETE' then Net::HTTP::Delete.new(uri, @headers)
      else               abort('Unknown method: ' + method)
      end
    end

    ##
    # Decodes the response from the server.
    def response_decode(response)
      return {} if response.body.nil?

      # Parse and return JSON
      begin
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError
        { error: 'Non-JSON response', result: response.body }
      end
    end

    ##
    # Does an HTTP request and returns the response.
    # Parameters are:
    # - +method+: HTTP method to use.
    # - +uri+:    URL for the request
    # - +body+:   Optional body of the request.
    # Returns the decoded response.
    def http(method, uri, body = nil)
      # Debug output
      puts 'Body: ' + body.to_json if ENV['DEBUG']

      # Start an HTTP connection
      begin
        response = Net::HTTP.start(@host, @port) do |http|
          # Create uri & request
          uri = uri(uri)
          req = http_method(method, uri)

          # Do the request
          http.request(req, body.to_json)
        end
      rescue StandardError, Timeout::Error => e
        abort("Error: #{e}")
      end

      response_decode(response)
    end

    ##
    # Does an HTTP +DELETE+ request to +uri+.
    # Returns the decoded response.
    def delete(uri)
      http('DELETE', uri)
    end

    ##
    # Does an HTTP +GET+ request to +uri+.
    # Returns the decoded response.
    def get(uri)
      http('GET', uri)
    end

    ##
    # Does an HTTP +PATCH+ request to +uri+.
    # Returns the decoded response.
    def patch(uri, body = nil)
      http('PATCH', uri, body)
    end

    ##
    # Does an HTTP +POST+ request to +uri+.
    # Returns the decoded response.
    def post(uri, body = nil)
      http('POST', uri, body)
    end

    ##
    # Does an HTTP +PUT+ request to +uri+.
    # Returns the decoded response.
    def put(uri, body = nil)
      http('PUT', uri, body)
    end
  end
end
