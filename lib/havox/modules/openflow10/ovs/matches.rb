# This dictionary structure translates Merlin match fields to OpenVSwitch
# readable fields. More details can be found at:
# http://www.pica8.com/document/v2.3/pdf/ovs-commands-reference.pdf

module Havox
  module OpenFlow10
    module OVS
      module Matches
        extend Havox::FieldParser

        FIELDS = {
          'ethSrc'     => :dl_src,
          'ethDst'     => :dl_dst,
          'ethTyp'     => :dl_type,
          'ipSrc'      => :nw_src,
          'ipDst'      => :nw_dst,
          'ipProto'    => :nw_proto,
          'nwProto'    => :nw_proto,
          'port'       => :in_port,
          'switch'     => :dp_id,
          'tcpSrcPort' => :tp_src,
          'tcpDstPort' => :tp_dst,
          'vlanId'     => :dl_vlan,
          'vlanPcp'    => :dl_vlan_pcp
        }

        def self.treat(hash)
          hash[:nw_src] = parsed_ipv4(hash[:nw_src]) unless hash[:nw_src].nil?
          hash[:nw_dst] = parsed_ipv4(hash[:nw_dst]) unless hash[:nw_dst].nil?
          hash
        end
      end
    end
  end
end
