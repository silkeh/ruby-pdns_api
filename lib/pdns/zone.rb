# PDNS Zone
module PDNS
  require_relative 'metadata'
  require_relative 'cryptokey'

  # Zone
  class Zone < API
    def initialize(server_id, zone_id, info = nil)
      @server_id = server_id
      @zone_id   = zone_id
      @info      = info
    end

    ## Zone interfaces

    # Returns zone information.
    def get
      @@api.get "/servers/#{@server_id}/zones/#{@zone_id}"
    end

    # Deletes this zone, all attached metadata and rrsets.
    def delete
      @@api.delete "/servers/#{@server_id}/zones/#{@zone_id}"
    end

    # Modifies present RRsets and comments.
    def modify(rrsets)
      @@api.patch "/servers/#{@server_id}/zones/#{@zone_id}", rrsets
    end

    # Modifies basic zone data (metadata).
    def change(rrsets)
      @@api.put "/servers/#{@server_id}/zones/#{@zone_id}", rrsets
    end

    ## Zone actions

    # Notify slaves for a zone
    def notify
      @@api.put "/servers/#{@server_id}/zones/#{@zone_id}/notify"
    end

    # Get the AXFR for a zone
    def axfr_retrieve
      @@api.put "/servers/#{@server_id}/zones/#{@zone_id}/axfr-retrieve"
    end

    # Export a zone
    def export
      @@api.get "/servers/#{@server_id}/zones/#{@zone_id}/export"
    end

    # Check a zone
    def check
      @@api.get "/servers/#{@server_id}/zones/#{@zone_id}/check"
    end

    ## Zone resources

    # Manipulate metadata for a zone
    def metadata(metadata_kind = nil)
      return Metadata.new(@server_id, @zone_id, metadata_kind) unless metadata_kind.nil?

      # TODO: /servers/:server_id/zones/:zone_name/metadata: GET, POST
    end

    # Change cryptokeys for a zone
    def cryptokeys(cryptokey_id = nil)
      return CryptoKey.new(@server_id, @zone_id, cryptokey_id) unless cryptokey_id.nil?

      # TODO: /servers/:server_id/zones/:zone_name/cryptokeys: GET, POST
    end

    ## Additional methods

    def apply(rrsets)
      rrsets.map! do |rrset|
        if rrset.key?(:records)
          rrset[:records] = [rrset[:records]] if rrset[:records].is_a?(String)
          abort('Error: records needs to be array') unless rrset[:records].is_a?(Array)
          rrset[:records].map! do |record|
            record = {
              'content'  => record[:content],
              'disabled' => !!record[:disabled] || !!rrset[:disabled],
              'set-ptr'  => !!record[:set_ptr]
            }
            next unless @@version == 0
            record.merge!(
              'name' => rrset[:name],
              'type' => rrset[:type],
              'ttl'  => rrset[:ttl]
            )
          end
        end

        # Convert symbols to strings
        hash_sym_to_string(rrset)
      end
      modify('rrsets' => rrsets)
    end

    def create_records(rrset)
      abort('Error: no records for add/update') unless rrset.key?(:records)

      rrset[:records] = [rrset[:records]] if rrset[:records].is_a?(String)

      rrset[:records].map do |value|
        value = { content: value } if value.is_a?(String)
        value
      end
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

    def update(*rrsets)
      # Set type and format records
      rrsets.map! do |rrset|
        rrset[:changetype] = 'REPLACE'
        rrset[:records] = create_records(rrset)
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
  end
end
