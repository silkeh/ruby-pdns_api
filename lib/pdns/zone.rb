# PDNS Zone
module PDNS
  require_relative 'metadata'
  require_relative 'cryptokey'

  # Zone
  class Zone < API
    attr_reader :id, :url

    def initialize(t_url, id, info = {})
      @id    = id
      @info  = info
      @r_url = "#{t_url}/zones"
      @url   = "#{t_url}/zones/#{id}"
    end

    ## Zone interfaces

    # Modifies present RRsets and comments.
    def modify(rrsets)
      @@api.patch(@url, rrsets)
    end

    # Modifies basic zone data (metadata).
    def change(rrsets)
      @@api.put(@url, rrsets)
    end

    ## Zone actions

    # Notify slaves for a zone
    def notify
      @@api.put "#{@url}/notify"
    end

    # Get the AXFR for a zone
    def axfr_retrieve
      @@api.put "#{@url}/axfr-retrieve"
    end

    # Export a zone
    def export
      @@api.get "#{@url}/export"
    end

    # Check a zone
    def check
      @@api.get "#{@url}/check"
    end

    ## Zone resources

    # Manipulate metadata for a zone
    def metadata(kind = nil, value = nil)
      return Metadata.new(@url, kind, value).create unless kind.nil? || value.nil?
      return Metadata.new(@url, kind) unless kind.nil?

      # Get all current metadata
      metadata = @@api.get("#{@url}/metadata")

      # Check for errors
      return metadata if metadata.is_a?(Hash) && metadata.key?('error')

      # Convert metadata to hash
      metadata.map! { |c| [c['kind'], c['metadata']] }.to_h
    end

    # Change cryptokeys for a zone
    def cryptokeys(id = nil)
      return CryptoKey.new(@url, id) unless id.nil?

      # Get all current metadata
      cryptokeys = @@api.get("#{@url}/cryptokeys")

      # Convert cryptokeys to hash
      cryptokeys.map! { |c| [c['id'], c] }.to_h
    end

    ## Additional methods
    def format_records(rrset)
      # Convert records string to single element array
      rrset[:records] = [rrset[:records]] if rrset[:records].is_a?(String)

      # Abort if it is something else
      abort('Error: records needs to be array') unless rrset[:records].is_a?(Array)

      # Format the records correctly
      rrset[:records].map! do |record|
        record = {
          'content'  => record[:content],
          'disabled' => !!record[:disabled] || !!rrset[:disabled],
          'set-ptr'  => !!record[:set_ptr]
        }
        next record unless @@version == 0
        record.merge(
          'name' => rrset[:name],
          'type' => rrset[:type],
          'ttl'  => rrset[:ttl]
        )
      end
      rrset
    end

    def apply(rrsets)
      rrsets.map! do |rrset|
        # Format the records in the RRset
        rrset = format_records(rrset) if rrset.key?(:records)

        # Convert symbols to strings
        hash_sym_to_string(rrset)
      end

      # Apply modification
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

    # Add records to the ones already existing
    # Only works from API v1 and up
    def add(*rrsets)
      # Get current zone data
      data = get

      # Return any errors
      return data if data.key?('error')

      # Run v0 version
      return add_v0(rrsets, data) if @@version == 0

      # Add these records to the rrset
      rrsets.map! do |rrset|
        current = data['rrsets'].select do |r|
          r['name'] == rrset[:name] && r['type'] == rrset[:type]
        end
        current = current.first['records'].map { |r| hash_string_to_sym(r) }

        rrset[:records] = current + create_records(rrset)
        rrset[:changetype] = 'REPLACE'
        rrset
      end
      apply(rrsets)
    end

    # Add records to the ones already existing
    # Only works from API v1 and down
    def add_v0(rrsets, data)
      # Add these records to the rrset
      rrsets.map! do |rrset|
        current = data['records'].select do |r|
          r['name'] == rrset[:name] && r['type'] == rrset[:type]
        end
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
