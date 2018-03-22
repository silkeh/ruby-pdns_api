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

require 'pdns_api/metadata'
require 'pdns_api/cryptokey'

##
#
module PDNS
  ##
  # Zone on a server.
  class Zone < API
    ##
    # @return [String] the ID of the zone.
    attr_reader :id

    ##
    # Creates a Zone object.
    #
    # @param http   [HTTP]   An HTTP object for interaction with the PowerDNS server.
    # @param parent [API]    This object's parent.
    # @param id     [String] ID of the zone.
    # @param info   [Hash]   Optional information of the zone.
    #
    def initialize(http, parent, id, info = {})
      @class  = :zones
      @http   = http
      @parent = parent
      @id     = id
      @info   = info
      @url    = "#{parent.url}/#{@class}/#{id}"
    end

    ##
    # Modifies information (records) of a zone.
    # Also formats records to match the API requirements.
    #
    # @param rrsets [Array] Changeset to send to the PowerDNS API.
    #
    # @return [Hash] result of the changeset.
    #
    # @example
    #  zone.modify([
    #     changetype: 'DELETE',
    #     name: 'www.example.com.',
    #     type: 'A'
    #  ])
    #
    def modify(rrsets)
      rrsets.map! do |rrset|
        rrset = format_records(rrset) if rrset.key?(:records)
        rrset
      end

      @http.patch(@url, rrsets: rrsets)
    end

    ##
    # Notifies slaves for a zone.
    # Only works for domains for which the server is a master.
    # @return [Hash] the result of the notification.
    def notify
      @http.put "#{@url}/notify"
    end

    ##
    # Retrieves the data for a zone.
    # Only works for domains for which the server is a slave.
    # @return [Hash] the result of the retrieval.
    def axfr_retrieve
      @http.put "#{@url}/axfr-retrieve"
    end

    ##
    # Exports the zone as a bind zone file.
    # @return [Hash] containing the Bind formatted zone in +:result+.
    def export
      data = @http.get "#{@url}/export"
      data.delete(:error) if data[:error] == 'Non-JSON response'
      data
    end

    ##
    # Checks the zone for errors.
    # @return [Hash] the result of the check.
    def check
      @http.get "#{@url}/check"
    end

    ##
    # Adds records to the zone. (addition from dachinat/ruby-pdns_api fork)
    #
    # The existing records are retrieved and merged with the ones given in +rrsets+.
    #
    # Elements of +rrsets+ can contain +:records+, which can be:
    # - A +String+ containing a single record value.
    # - An +Array+ containing record values.
    # - An +Array+ containing hashes as specified in the PowerDNS API.
    #
    # @param rrsets [Array<Object>] Array of Hashes containing records to replace.
    #
    # @return [Hash] Hash containing result of the operation.
    #
    # @example
    #   zone.add({
    #     name: 'www0.example.com.',
    #     type: 'A',
    #     ttl:  86_400,
    #     records: '127.0.1.1',
    #   }, {
    #     name: 'www1.example.com.',
    #     type: 'A',
    #     ttl:  86_400,
    #     records: ['127.0.1.1', '127.0.0.1'],
    #   }, {
    #     name: 'www2.example.com.',
    #     type: 'A',
    #     ttl:  86_400,
    #     records: [{content: '127.0.1.1'},{content: '127.0.0.1', disabled: true}],
    #   })
    #
    def add(*rrsets)
      # Get current zone data
      data = get

      # Return any errors
      return data if data.key?(:error)

      # Add these records to the rrset
      rrsets.map! do |rrset|
        # Get current data from rrset
        rrset[:changetype] = 'REPLACE'

        # See if there are no records for type
        if data[:rrsets].select { |r| r[:type] == rrset[:type] && r[:name] == rrset[:name] }.blank?
          rrset[:records] = ensure_array(rrset[:records])
        else
          current = current_records(rrset, data)
          rrset[:records]    = current + ensure_array(rrset[:records])
        end

        rrset
      end
      modify(rrsets)
    end

    ##
    # Updates (replaces) records for a name/type combination in the zone.
    #
    # Elements of +rrsets+ can contain +:records+, which can be:
    # - A +String+ containing a single record value.
    # - An +Array+ containing record values.
    # - An +Array+ containing hashes as specified in the PowerDNS API.
    #
    # @param rrsets [Array<Object>] Array of Hashes containing records to replace.
    #
    # @return [Hash] Hash containing result of the operation.
    #
    # @example
    #   zone.update({
    #     name: 'www0.example.com.',
    #     type: 'A',
    #     ttl:  86_400,
    #     records: '127.0.1.1'
    #   }, {
    #     name: 'www1.example.com.',
    #     type: 'A',
    #     ttl:  86_400,
    #     records: ['127.0.1.1', '127.0.0.1']
    #   }, {
    #     name: 'www2.example.com.',
    #     type: 'A',
    #     ttl:  86_400,
    #     records: [{content: '127.0.1.1'},{content: '127.0.0.1', disabled: true}]
    #   })
    #
    def update(*rrsets)
      # Set type and format records
      rrsets.map! do |rrset|
        rrset[:changetype] = 'REPLACE'
        rrset[:records] = ensure_array(rrset[:records])
        rrset
      end
      modify(rrsets)
    end

    ##
    # Updates records contents for a name/type combination in the zone. (addition from dachinat/ruby-pdns_api fork)
    #
    # Elements of +rrsets+ can contain +:records+, which can be:
    # - A +String+ containing a single record value.
    # - An +Array+ containing record values.
    # - An +Array+ containing hashes as specified in the PowerDNS API.
    #
    # @param old_record [Array<Object>] Array containing hash of record that will be replaced.
    # @param rrsets [Array<Object>] Array of Hashes containing new records.
    #
    # @return [Hash] Hash containing result of the operation.
    #
    # @example
    #   zone.update_record({
    #     name: 'www0.example.com.',
    #     type: 'A',
    #     ttl:  86_400,
    #     records: [{
    #       content: '127.0.1.1',
    #       disabled: false
    #     }]
    #   }, {
    #     name: 'www0.example.com.',
    #     type: 'AAAA',
    #     ttl:  86_400,
    #     records: [{
    #       content: '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
    #       disabled: false
    #     }]
    #   })
    def update_record(old_record, *rrsets)
      remove_record(old_record)
      add(rrsets[0])
    end

    ##
    # Removes all records for a name/type combination from the zone.
    #
    # @param rrsets [Array<Object>] Array of Hashes to delete.
    #  The Hash(es) in the Array should contain +:name+ and +:type+.
    #
    # @return [Hash] Hash containing result of the operation.
    #
    # @example
    #   zone.remove({
    #     name: 'www0.example.com.',
    #     type: 'A'
    #   }, {
    #     name: 'www1.example.com.',
    #     type: 'A'
    #   })
    #
    def remove(*rrsets)
      # Set type and format records
      rrsets.map! do |rrset|
        rrset[:changetype] = 'DELETE'
        rrset
      end
      modify(rrsets)
    end

    ##
    # Removes all records with exception of SOA. (addition from dachinat/ruby-pdns_api fork)
    #
    # @param nameservers [Array<Object>] Array of nameservers to leave.
    #
    # @return [Hash] Hash containing result of the operation.
    #
    # @example
    #   zone.remove_all
    #
    def remove_all(nameservers=[])
      data = get

      return data if data.key?(:error)

      rrsets = data[:rrsets]

      rrsets.select! { |r| r[:type] != "SOA" && (r[:type] != "NS" && !nameservers.include?(r[:content])) }

      rrsets.map! do |rrset|
        rrset[:changetype] = 'DELETE'
        rrset
      end

      modify(rrsets)
    end

    ##
    # Removes specified records for a name/type combination from the zone. (addition from dachinat/ruby-pdns_api fork)
    #
    # @param rrsets [Array<Object>] Array of Hashes having records to delete.
    #  The Hash(es) in the Array should contain +:name+ and +:type+.
    #
    # @return [Hash] Hash containing result of the operation.
    #
    # @example
    #   zone.remove_record({
    #     name: "www0.example.com",
    #     type: "A",
    #     ttl: 3600,
    #     records: [{
    #       content: "15.7.7.607",
    #       disabled: false
    #     }]
    #   })
    def remove_record(*rrsets)
      # Get current zone data
      data = get

      # Return any errors
      return data if data.key?(:error)

      # Remove needed records from rrset
      rrsets.map! do |rrset|
        rrset[:changetype] = 'REPLACE'

        # See if there are no records for type
        if data[:rrsets].select { |r| r[:type] == rrset[:type] && r[:name] == rrset[:name] }.blank?
          rrset[:records] = []
        else
          current = current_records(rrset, data)
          rrset[:records] = current - ensure_array(rrset[:records])
        end
        rrset
      end
      modify(rrsets)
    end

    ##
    # Returns existing metadata or creates a +Metadata+ object.
    #
    # @param kind  [String, nil] The kind of metadata.
    # @param value [String, nil] The value of the metadata.
    #
    # @return [Metadata, Hash] Hash containing all metadata, or single +Metadata+ object.
    #   - If +kind+ is not set the current metadata is returned in a +Hash+.
    #   - If +kind+ is set a +Metadata+ object is returned using the provided +kind+.
    #   - If +value+ is set as well, a complete Metadata object is returned.
    #
    # @example
    #  # Retrieve all metadata in a hash
    #  zone.metadata
    #  # Create a metadata object
    #  meta = zone.metadata('ALLOW-AXFR-FROM')
    #  puts meta.get
    #  # Create a metadata object with a value
    #  meta = zone.metadata('ALLOW-AXFR-FROM','AUTO-NS')
    #  meta.change
    #
    def metadata(kind = nil, value = nil)
      return Metadata.new(@http, self, kind, value) unless kind.nil? || value.nil?
      return Metadata.new(@http, self, kind) unless kind.nil?

      # Get all current metadata
      metadata = @http.get("#{@url}/metadata")

      # Check for errors
      return metadata if metadata.is_a?(Hash) && metadata.key?(:error)

      # Convert metadata to hash
      metadata.map { |c| [c[:kind], c[:metadata]] }.to_h
    end

    ##
    # Returns existing or creates a +CryptoKey+ object.
    #
    #
    #
    #
    #
    # @param id [Integer, nil] ID of a +CryptoKey+.
    #
    # @return [Hash, CryptoKey] Hash of +CryptoKeys+ or a single +CryptoKey+.
    #   - If +id+ is not set the current servers are returned in a hash
    #     containing +CryptoKey+ objects.
    #   - If +id+ is set a +CryptoKey+ object with the provided ID is returned.
    #
    # @example
    #  ckeys = zone.cryptokeys
    #  ckey  = zone.cryptokey(12)
    #
    def cryptokeys(id = nil)
      return CryptoKey.new(@http, self, id) unless id.nil?

      # Get all current metadata
      cryptokeys = @http.get("#{@url}/cryptokeys")

      # Convert cryptokeys to hash
      cryptokeys.map { |c| [c[:id], CryptoKey.new(@http, self, c[:id], c)] }.to_h
    end

    private

    ##
    # Formats a single record to match what is required by the API.
    #
    # @param record [String, Hash] Record to format.
    # @return [Hash] Formatted record.
    #
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

    ##
    # Format the records in an RRset te match what is required by the API.
    # @param rrset [Hash] RRset of which to format the records.
    # @return [Hash] Formatted RRset.
    #
    def format_records(rrset)
      # Ensure existence of required keys
      rrset[:records].map! do |record|
        # Format the record content
        record = format_single_record(record)

        # Add disabled from the rrset
        record[:disabled] ||= !!rrset[:disabled]

        # Return record
        next record unless @http.version == 0

        # But add some more for APIv0
        record.merge(name: rrset[:name], type: rrset[:type], ttl: rrset[:ttl])
      end
      rrset
    end

    ##
    # Returns the records matching the ones in +rrset+ from +data+.
    #
    # @param rrset [Hash] RRset to match current records with.
    # @param data  [Hash] RRsets currently on the server. Should be the result from +get+.
    # @return [Array] Currently existing records.
    #
    def current_records(rrset, data)
      # Get the records from the data, `records` is v0, `rrsets` is v1
      records = data[:records] || data[:rrsets]

      # Select records matching type/name
      current = records.select { |r| r[:name] == rrset[:name] && r[:type] == rrset[:type] }

      # Get only content/disabled for API v0
      if @http.version == 0
        current.map! { |record| { content:  record[:content], disabled: record[:disabled] } }
      end

      # For API v1 there is only one element containing all records
      current = current.first[:records] unless @http.version == 0

      # Return the records
      current
    end
  end
end
