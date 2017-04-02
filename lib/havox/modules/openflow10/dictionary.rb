module Havox
  module OpenFlow10
    module Dictionary
      # This dictionary file translates Merlin match fields to the official
      # OpenFlow 1.0 nomenclatures, as described in the OpenFlow specifications
      # at http://archive.openflow.org/documents/openflow-spec-v1.0.0.pdf.

      MATCHES = {
        'ethSrc'     => :eth_src,
        'ethDst'     => :eth_dst,
        'ethTyp'     => :eth_type,                                              # https://www.iana.org/assignments/ieee-802-numbers/ieee-802-numbers.xhtml
        'ipSrc'      => :ipv4_src,
        'ipDst'      => :ipv4_dst,
        'ipProto'    => :ip_proto,                                              # http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
        'nwProto'    => :ip_proto,
        'port'       => :in_port,
        'switch'     => :dp_id,
        'tcpSrcPort' => :tcp_src,
        'tcpDstPort' => :tcp_dst,
        'vlanId'     => :vlan_vid,
        'vlanPcp'    => :vlan_pcp
      }
    end
  end
end
