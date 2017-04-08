module Havox
  module OpenFlow10
    module Dictionary
      # This dictionary file translates Merlin match fields to Trema readable
      # fields, based on the official OpenFlow 1.0 nomenclatures, as described
      # in the OpenFlow specifications at:
      # http://archive.openflow.org/documents/openflow-spec-v1.0.0.pdf

      MATCHES = {
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
    end
  end
end
