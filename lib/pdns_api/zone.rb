# PDNS Zone
module PDNS
  require_relative 'metadata'
  require_relative 'cryptokey'

  # Zone
  class Zone < API
    attr_reader :id, :url

    def initialize(http, t_url, id, info = {})
      @http  = http
      @id    = id
      @info  = info
      @r_url = "#{t_url}/zones"
      @url   = "#{t_url}/zones/#{id}"
    end

    ## Zone interfaces

    # Modifies present RRsets and comments.
    def modify(rrsets)
      rrsets.map! { |rrset| format_records(rrset) if rrset.key?(:records) }

      @http.patch(@url, rrsets: rrsets)
    end

    # Modifies basic zone data (metadata).
    def change(rrsets)
      @http.put(@url, rrsets)
    end

    ## Zone actions

    # Notify slaves for a zone
    def notify
      @http.put "#{@url}/notify"
    end

    # Get the AXFR for a zone
    def axfr_retrieve
      @http.put "#{@url}/axfr-retrieve"
    end

    # Export a zone
    def export
      @http.get "#{@url}/export"
    end

    # Check a zone
    def check
      @http.get "#{@url}/check"
    end

    ## Zone resources

    # Manipulate metadata for a zone
    def metadata(kind = nil, value = nil)
      return Metadata.new(@http, @url, kind, value).create unless kind.nil? || value.nil?
      return Metadata.new(@http, @url, kind) unless kind.nil?

      # Get all current metadata
      metadata = @http.get("#{@url}/metadata")

      # Check for errors
      return metadata if metadata.is_a?(Hash) && metadata.key?(:error)

      # Convert metadata to hash
      metadata.map! { |c| [c[:kind], c[:metadata]] }.to_h
    end

    # Change cryptokeys for a zone
    def cryptokeys(id = nil)
      return CryptoKey.new(@http, @url, id) unless id.nil?

      # Get all current metadata
      cryptokeys = @http.get("#{@url}/cryptokeys")

      # Convert cryptokeys to hash
      cryptokeys.map! { |c| [c[:id], CryptoKey.new(@http, @url, c[:id], c)] }.to_h
    end

    ## Additional methods

    def format_single_record(record)
      # Ensure content
      record = { content: record } if record.is_a? String

      # Add disabled and set_ptr
      record[:disabled] = !!record[:disabled]
      record[:set_ptr]  = !!record[:set_ptr]

      # Replace some symbols
      record[:'set-ptr'] = record.delete :set_ptr
      record
    end

    # Add required items to records in an rrset
    def format_records(rrset)
      # Abort if rrset is something else than an array
      abort('Error: records needs to be array') unless rrset[:records].is_a? Array

      # Ensure existence of required keys
      rrset[:records].map! do |record|
        # Format the record content
        record = format_single_record(record)

        # Add disabled from the rrset
        record[:disabled] ||= !!rrset[:disabled]

        # Return record
        next record unless @version == 0

        # But add some more for APIv0
        record.merge(name: rrset[:name], type: rrset[:type], ttl: rrset[:ttl])
      end
      rrset
    end

    # Add records to the ones already existing
    # Only works from API v1 and up
    def add(*rrsets)
      # Get current zone data
      data = get

      # Return any errors
      return data if data.key?(:error)

      # Run v0 version
      return add_v0(rrsets, data) if @version == 0

      # Add these records to the rrset
      rrsets.map! do |rrset|
        # Get current data from rrset
        current = data[:rrsets].select { |r| r[:name] == rrset[:name] && r[:type] == rrset[:type] }

        # Merge data
        rrset[:records]    = current.first[:records] + ensure_array(rrset[:records])
        rrset[:changetype] = 'REPLACE'
        rrset
      end
      modify(rrsets)
    end

    # Add records to the ones already existing
    # Only works from API v1 and down
    def add_v0(rrsets, data)
      # Add these records to the rrset
      rrsets.map! do |rrset|
        current = data[:records].select do |r|
          r[:name] == rrset[:name] && r[:type] == rrset[:type]
        end
        current.map! do |record|
          {
            content:  record[:content],
            disabled: record[:disabled]
          }
        end
        rrset[:records] = current + ensure_array(rrset[:records])
        rrset[:changetype] = 'REPLACE'
        rrset
      end
      modify(rrsets)
    end

    def update(*rrsets)
      # Set type and format records
      rrsets.map! do |rrset|
        rrset[:changetype] = 'REPLACE'
        rrset[:records] = ensure_array(rrset[:records])
        rrset
      end
      modify(rrsets)
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
