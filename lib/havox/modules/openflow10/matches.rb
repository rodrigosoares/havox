module Havox
  module OpenFlow10
    module Matches
      # This dictionary file translates Merlin match fields to Trema readable
      # fields, based on the official OpenFlow 1.0 nomenclatures, as described
      # in the OpenFlow specifications at:
      # http://archive.openflow.org/documents/openflow-spec-v1.0.0.pdf

      FIELDS = {
        'ethSrc'     => :source_mac_address,
        'ethDst'     => :destination_mac_address,
        'ethTyp'     => :ether_type,                                            # https://www.iana.org/assignments/ieee-802-numbers/ieee-802-numbers.xhtml
        'ipSrc'      => :source_ip_address,
        'ipDst'      => :destination_ip_address,
        'ipProto'    => :ip_protocol,                                           # http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
        'nwProto'    => :ip_protocol,
        'port'       => :in_port,
        'switch'     => :dp_id,
        'tcpSrcPort' => :transport_source_port,
        'tcpDstPort' => :transport_destination_port,
        'vlanId'     => :vlan_vid,
        'vlanPcp'    => :vlan_priority
      }

      def self.fields_treated(hash)
        hash[:ether_type]                 = hash[:ether_type].to_i unless hash[:ether_type].nil?
        hash[:source_ip_address]          = parsed_ipv4(hash[:source_ip_address]) unless hash[:source_ip_address].nil?
        hash[:destination_ip_address]     = parsed_ipv4(hash[:destination_ip_address]) unless hash[:destination_ip_address].nil?
        hash[:ip_protocol]                = hash[:ip_protocol].to_i unless hash[:ip_protocol].nil?
        hash[:in_port]                    = hash[:in_port].to_i unless hash[:in_port].nil?
        hash[:transport_source_port]      = hash[:transport_source_port].to_i unless hash[:transport_source_port].nil?
        hash[:transport_destination_port] = hash[:transport_destination_port].to_i unless hash[:transport_destination_port].nil?
        hash[:vlan_vid]                   = hash[:vlan_vid].to_i unless hash[:vlan_vid].nil?
        hash[:vlan_priority]              = hash[:vlan_priority].to_i unless hash[:vlan_priority].nil?
        hash
      end

      private

      def self.parsed_ipv4(ip_integer)
        ip_integer = ip_integer.to_i
        value = ip_integer.positive? ? ip_integer : (2**32 - ip_integer.abs)    # Handles two's complement integers.
        bits = value.to_s(2).rjust(32, '0')                                     # Transforms the string number into a 32-bit sequence.
        octets = bits.scan(/\d{8}/).map { |octet_bits| octet_bits.to_i(2) }     # Splits the sequence into decimal octets.
        octets.join('.')                                                        # Returns the joined octets.
      end
    end
  end
end
