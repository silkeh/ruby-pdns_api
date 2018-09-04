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
  # Class for connecting to the PowerDNS API.
  class HTTP
    ##
    # @return [Hash] the headers used for requests.
    attr_accessor :headers

    ##
    # @return [Integer] the PowerDNS API version in use.
    attr_reader :version

    ##
    # Creates a PDNS connection.
    #
    # @param args [Hash] should include:
    #   - +:host+: hostname or IP address of the PowerDNS server.
    #   - +:key+:  API key for the PowerDNS server.
    #   It may include:
    #   - +:port+:    Port the server listens on. Defaults to +8081+.
    #   - +:version+: Version of the API to use.  Defaults to +1+.
    #   - +:scheme+:  Scheme - HTTP or HTTPS.  Defaults to +http+.
    #   The version of the API depends on the version of PowerDNS.
    #
    def initialize(args)
      @host    = args[:host]
      @headers = { 'X-API-Key' => args[:key] }
      @port    = args.key?(:port)    ? args[:port]    : 8081
      @version = args.key?(:version) ? args[:version] : api_version
      @scheme  = args.key?(:scheme)  ? args[:scheme]  : 'http'
    end

    ##
    # Get the version of the API.
    #
    # @return [Integer] version of the PowerDNS API.
    #
    def api_version
      # Do a request for the API endpoints
      net = Net::HTTP::Get.new('/api', @headers)
      res = http(net)

      # APIv0 does not play nice.
      return 0 unless res.is_a? Array

      # Return the highest API version.
      res.map { |a| a[:version] }.max.to_i
    end

    ##
    # Returns the correct URI for a request.
    # This depends on the API version.
    #
    # @param request [String] Requested URI.
    # @return [String] Correct URI for the API version.
    #
    def uri(request = '')
      base = ''
      base = "/api/v#{@version}" unless @version == 0 || request[0..3] == '/api'
      base + request
    end

    ##
    # Decodes the response from the server.
    #
    # @param response [Net::HTTPResponse] response to decode.
    # @return [Hash] decoded response.
    #
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
    #
    # @param net  [Net::HTTP] object to use in request.
    # @param body [Hash]      body of the request.
    #
    # @return [Hash] decoded response from server.
    #
    def http(net, body = nil)
      # Debug output
      puts "#{net.method}: #{net.path}\nBody: #{body.to_json}" if ENV['DEBUG']

      # Start an HTTP connection
      begin
        response = Net::HTTP.start(@host, @port, use_ssl: @scheme == 'https') do |http|
          # Do the request
          http.request(net, body.to_json)
        end
      rescue StandardError, Timeout::Error => e
        return { error: e.to_s }
      end

      response_decode(response)
    end

    ##
    # Does an HTTP +DELETE+ request to +uri+.
    #
    # @param uri [String] URI for request.
    # @return [Hash] the decoded response.
    #
    def delete(uri)
      uri = uri(uri)
      net = Net::HTTP::Delete.new(uri, @headers)
      http(net)
    end

    ##
    # Does an HTTP +GET+ request to +uri+.
    #
    # @param uri [String] URI for request.
    # @return [Hash] the decoded response.
    #
    def get(uri)
      uri = uri(uri)
      net = Net::HTTP::Get.new(uri, @headers)
      http(net)
    end

    ##
    # Does an HTTP +PATCH+ request to +uri+.
    #
    # @param uri [String] URI for request.
    # @param body [Hash]  Body to include in request.
    # @return [Hash] the decoded response.
    #
    def patch(uri, body = nil)
      uri = uri(uri)
      net = Net::HTTP::Patch.new(uri, @headers)
      http(net, body)
    end

    ##
    # Does an HTTP +POST+ request to +uri+.
    #
    # @param uri [String] URI for request.
    # @param body [Hash]  Body to include in request.
    # @return [Hash] the decoded response.
    #
    def post(uri, body = nil)
      uri = uri(uri)
      net = Net::HTTP::Post.new(uri, @headers)
      http(net, body)
    end

    ##
    # Does an HTTP +PUT+ request to +uri+.
    #
    # @param uri [String] URI for request.
    # @param body [Hash]  Body to include in request.
    # @return [Hash] the decoded response.
    #
    def put(uri, body = nil)
      uri = uri(uri)
      net = Net::HTTP::Put.new(uri, @headers)
      http(net, body)
    end
  end
end
