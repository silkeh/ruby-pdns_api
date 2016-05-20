require 'json'
require 'net/http'

# Class for the PowerDNS API
class PDNS
  attr_reader :last_res, :version

  # Initialise the class
  def initialize(host, port, api_key, v = 1)
    @host    = host
    @port    = port
    @api_key = api_key
    @headers = { 'X-API-Key' => api_key }
    @base    = "/api/v#{v}" unless v == 0
    @version = v
  end

  ## Main methods

  # Get or set info about a server
  def servers(server_id = nil, data = nil)
    uri = '/servers'
    uri << "/#{server_id}" unless server_id.nil?

    return get(uri) if data.nil?
    # TODO: /server: PUT, POST, DELETE
    # TODO: /servers/:server_id: ?
  end

  # Get or set server config
  def config(server_id, config_setting_name = nil, data = nil)
    return get("/servers/#{server_id}/config") if config_setting_name.nil? && data.nil?
    return get("/servers/#{server_id}/#{config_setting_name}") if data.nil?
    # TODO: /config: POST
    # TODO: /config/:config_setting_name: PUT
  end

  # Manipulate zone data
  def zones(server_id, zone_id = nil, data = nil)
    return server_zones(server_id, data) if zone_id.nil?
    zone_zones(server_id, zone_id, data)
  end

  # Get zones or create one
  def server_zones(server_id, data = nil)
    return get("/servers/#{server_id}/zones") if data.nil?
    post("/servers/#{server_id}/zones", rrsets)
  end

  # Manipulate specific zone data
  def zone_zones(server_id, zone_id, rrsets = nil)
    case rrsets
    when nil      then get("/servers/#{server_id}/zones/#{zone_id}")
    when 'delete' then delete("/servers/#{server_id}/zones/#{zone_id}")
    else               patch("/servers/#{server_id}/zones/#{zone_id}", rrsets)
    end
    # TODO: /servers/:server_id/zones/:zone_id: PUT (undocumented)
  end

  ## Zone specific methods

  # Notify slaves for a zone
  def zone_notify(server_id, zone_id)
    put "/servers/#{server_id}/zones/#{zone_id}/notify"
  end

  # Get the AXFR for a zone
  def zone_axfr_retrieve(server_id, zone_id)
    put "/servers/#{server_id}/zones/#{zone_id}/axfr-retrieve"
  end

  # Export a zone
  def zone_export(server_id, zone_id)
    get "/servers/#{server_id}/zones/#{zone_id}/export"
  end

  # Check a zone
  def zone_check(server_id, zone_id)
    get "/servers/#{server_id}/zones/#{zone_id}/check"
  end

  # Manipulate metadata for a zone
  def metadata(server_id, zone_id, metadata_kind = nil)
    # TODO: /servers/:server_id/zones/:zone_name/metadata: GET, POST
    # TODO: /servers/:server_id/zones/:zone_name/metadata/:metadata_kind: GET, PUT, DELETE
  end

  # Change cryptokeys for a zone
  def cryptokeys(server_id, zone_id, cryptokey_id = nil)
    # TODO: /servers/:server_id/zones/:zone_name/cryptokeys: GET, POST
    # TODO: /servers/:server_id/zones/:zone_name/cryptokeys/:cryptokey_id: GET, PUT, DELETE
  end

  ## Server specific methods

  def server_cache(server_id, domain)
    # TODO: /servers/:server_id/cache/flush?domain=:domain: PUT
  end

  def server_search_log(server_id, search_term)
    # TODO: /servers/:server_id/search-log?q=:search_term: GET
  end

  def server_statistics(server_id)
    # TODO: /servers/:server_id/statistics: GET
  end

  def server_trace(server_id)
    # TODO: /servers/:server_id/trace: GET, PUT
  end

  def server_failures(server_id)
    # TODO: /servers/:server_id/failures: GET, PUT
  end

  def server_overrides(server_id, override_id = nil)
    # TODO: /servers/:server_id/overrides: GET, POST
    # TODO: /servers/:server_id/overrides/:override_id: GET, PUT, DELETE
  end

  # Create a Server object
  def new_server(server_id)
    PDNS::Server.new(self, server_id)
  end

  # Create a Zone object
  def new_zone(server_id, zone_id)
    PDNS::Zone.new(self, server_id, zone_id)
  end

  # Aliases for methods
  alias server new_server
  alias zone new_zone

  private

  # Do an HTTP request
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
  def http(method, uri, body = nil)
    # Start an HTTP connection
    @last_res = Net::HTTP.start(@host, @port) do |http|
      # Creat uri
      uri = @base + uri unless @base.nil?

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

    # Parse and return JSON
    JSON.parse @last_res.body
  end

  # Do a DELETE request
  def delete(uri, body = nil)
    http('PUT', uri, body)
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

  # Class for server manipulation
  class Server
    def initialize(pdns, server_id)
      @pdns      = pdns
      @server_id = server_id
    end

    def new_zone(zone_id)
      @pdns.new_zone(@server_id, zone_id)
    end

    alias zone new_zone

    def get(data = nil)
      @pdns.servers(@server_id, data)
    end

    def config(config_setting_name = nil, data = nil)
      @pdns.config(@server_id, config_setting_name, data)
    end

    def zones(data = nil)
      @pdns.server_zones(@server_id, data)
    end

    def cache(domain)
      @pdns.server_cache(@server_id, domain)
    end

    def search_log(search_term)
      @pdns.server_statistics(@server_id, search_term)
    end

    def statistics
      @pdns.server_statistics(@server_id)
    end

    def trace
      @pdns.server_trace(@server_id)
    end

    def failures
      @pdns.server_failures(@server_id)
    end

    def overrides(override_id = nil)
      @pdns.server_overrides(@server_id, override_id)
    end
  end

  # Class for zone manipulation
  class Zone
    def initialize(pdns, server_id, zone_id)
      @pdns      = pdns
      @server_id = server_id
      @zone_id   = zone_id
    end

    def apply(rrsets)
      rrsets.map! do |rrset|
        rrset[:records].map! do |record|
          record = {
            'content'  => record[:content],
            'disabled' => !!record[:disabled] || !!rrset[:disabled],
            'set-ptr'  => !!record[:set_ptr]
          }
          next unless @pdns.version == 0
          record.merge!(
            'name' => rrset[:name],
            'type' => rrset[:type],
            'ttl'  => rrset[:ttl]
          )
        end if rrset.key?(:records)

        # Convert symbols to strings
        rrset.map { |symbol, value| [symbol.to_s, value] }.to_h
        # {
        #     'name'       => rrset[:name],
        #     'type'       => rrset[:type],
        #     'ttl'        => rrset[:ttl],
        #     'changetype' => rrset[:change_type],
        #     'records'    => rrset[:records],
        #     'comments'   => rrset[:comments],
        # }
      end
      modify('rrsets' => rrsets)
    end

    def create_records(rrset)
      rrset[:records].map do |value|
        value = { content: value } if value.is_a?(String)
        value
      end
    end

    def update(*rrsets)
      # Set type and format records
      rrsets.map! do |rrset|
        rrset[:changetype] = 'REPLACE'
        rrset[:records] = create_records(rrset)
        rrset
      end
      apply(rrsets)
    end

    def add(*rrsets)
      # Get current zone data
      data = get['records']

      # Add these records to the rrset
      rrsets.map! do |rrset|
        current = data.select { |r| r['name'] == rrset[:name] && r['type'] == rrset[:type] }
        current.map! do |record|
          {
            content:  record['content'],
            disabled: record['disabled']
          }
        end
        rrset[:records] = current + create_records(rrset)
        rrset[:changetype] = 'REPLACE'
        rrset
      end
      apply(rrsets)
    end

    def remove(*rrsets)
      # Set type and format records
      rrsets.map! do |rrset|
        rrset[:changetype] = 'DELETE'
        rrset
      end
      apply(rrsets)
    end

    def delete
      @pdns.zone_zones(@server_id, @zone_id, 'delete')
    end

    def get
      @pdns.zone_zones(@server_id, @zone_id)
    end

    def put(rrset)
      # TODO: Implement PUT (undocumented)
    end

    def modify(rrset)
      @pdns.zone_zones(@server_id, @zone_id, rrset)
    end

    def notify
      @pdns.zone_notify(@server_id, @zone_id)
    end

    def axfr_retrieve
      @pdns.zone_axfr_retrieve(@server_id, @zone_id)
    end

    def export
      @pdns.zone_axfr_retrieve(@server_id, @zone_id)
    end

    def check
      @pdns.zone_check(@server_id, @zone_id)
    end

    def metadata(metadata_kind = nil)
      @pdns.metadata(@server_id, @zone_id, metadata_kind)
    end

    def cryptokeys(cryptokey_id = nil)
      @pdns.cryptokeys(@server_id, @zone_id, cryptokey_id)
    end
  end
end
