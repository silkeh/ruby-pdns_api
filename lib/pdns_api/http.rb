##
#
module PDNS
  ##
  # Class for connecting to the PowerDNS API.
  class HTTP
    ##
    # The headers used for requests.
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
    # - +net+:  Net::HTTP method object to use in request.
    # - +body+: Optional body of the request.
    # Returns the decoded response.
    def http(net, body = nil)
      # Debug output
      puts 'Body: ' + body.to_json if ENV['DEBUG']

      # Start an HTTP connection
      begin
        response = Net::HTTP.start(@host, @port) do |http|
          # Do the request
          http.request(net, body.to_json)
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
      uri = uri(uri)
      net = Net::HTTP::Delete.new(uri, @headers)
      http(net)
    end

    ##
    # Does an HTTP +GET+ request to +uri+.
    # Returns the decoded response.
    def get(uri)
      uri = uri(uri)
      net = Net::HTTP::Get.new(uri, @headers)
      http(net)
    end

    ##
    # Does an HTTP +PATCH+ request to +uri+.
    # Returns the decoded response.
    def patch(uri, body = nil)
      uri = uri(uri)
      net = Net::HTTP::Patch.new(uri, @headers)
      http(net, body)
    end

    ##
    # Does an HTTP +POST+ request to +uri+.
    # Returns the decoded response.
    def post(uri, body = nil)
      uri = uri(uri)
      net = Net::HTTP::Post.new(uri, @headers)
      http(net, body)
    end

    ##
    # Does an HTTP +PUT+ request to +uri+.
    # Returns the decoded response.
    def put(uri, body = nil)
      uri = uri(uri)
      net = Net::HTTP::Put.new(uri, @headers)
      http(net, body)
    end
  end
end
