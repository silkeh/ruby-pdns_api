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
    # The ID of the zone.
    attr_reader :id

    ##
    # Creates a Zone object.
    #
    # - +http+:   An HTTP object for interaction with the PowerDNS server.
    # - +parent+: This object's parent.
    # - +id+:     ID of the zone.
    # - +info+:   Optional information of the zone.
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
    def modify(rrsets)
      rrsets.map! do |rrset|
        rrset = format_records(rrset) if rrset.key?(:records)
        rrset
      end

      @http.patch(@url, rrsets: rrsets)
    end

    ##
    # Modifies basic zone data (metadata).
    # +rrset+ is used as changeset for the update.
    def change(rrsets)
      @http.put(@url, rrsets)
    end

    ##
    # Notifies slaves for a zone.
    # Only works for domains for which the server is a master.
    # Returns the result of the notification.
    def notify
      @http.put "#{@url}/notify"
    end

    ##
    # Retrieves the data for a zone.
    # Only works for domains for which the server is a slave.
    # Returns the result of the retrieval.
    def axfr_retrieve
      @http.put "#{@url}/axfr-retrieve"
    end

    ##
    # Exports the zone as a bind zone file.
    # Returns a hash containing the zone in +:result+.
    def export
      data = @http.get "#{@url}/export"
      data.delete(:error) if data[:error] == 'Non-JSON response'
      data
    end

    ##
    # Checks the zone for errors.
    # Returns the result of the check.
    def check
      @http.get "#{@url}/check"
    end

    ##
    # Adds records to the ones already existing in the zone.
    #
    # The existing records are retrieved and merged with the ones given in +rrsets+.
    def add(*rrsets)
      # Get current zone data
      data = get

      # Return any errors
      return data if data.key?(:error)

      # Add these records to the rrset
      rrsets.map! do |rrset|
        # Get current data from rrset
        current = current_records(rrset, data)

        # Merge data
        rrset[:records]    = current + ensure_array(rrset[:records])
        rrset[:changetype] = 'REPLACE'
        rrset
      end
      modify(rrsets)
    end

    ##
    # Updates (replaces) records for a name/type combination in the zone.
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
    # Removes all records for a name/type combination from the zone.
    def remove(*rrsets)
      # Set type and format records
      rrsets.map! do |rrset|
        rrset[:changetype] = 'DELETE'
        rrset
      end
      modify(rrsets)
    end

    ##
    # Returns existing metadata or creates a +Metadata+ object.
    #
    # If +kind+ is not set the current metadata is returned in a hash.
    #
    # If +kind+ is set a +Metadata+ object is returned using the provided +kind+.
    # If +value+ is set as well, a complete Metadata object is returned.
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
    # If +id+ is not set the current servers are returned in a hash
    # containing +CryptoKey+ objects.
    #
    # If +id+ is set a +CryptoKey+ object with the provided ID is returned.
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
    # +data+ should be the result from +get+.
    def current_records(rrset, data)
      # Get the records from the data, `records` is v0, `rrset` is v1
      records = data[:records] || data[:rrset]

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
