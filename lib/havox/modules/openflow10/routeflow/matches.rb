# This dictionary structure translates Merlin match fields to RouteFlow
# readable fields. Since the current version of RouteFlow does not support
# all returned fields yet, some of them were inferred based on the others
# (those are marked as 'inferred'). As RouteFlow gets updated, the inferred
# names can be updated as well. RouteFlow's main repo can be accessed at:
# https://github.com/routeflow/RouteFlow.

module Havox
  module OpenFlow10
    module RouteFlow
      module Matches
        extend Havox::FieldParser

        FIELDS = {
          'ethSrc'     => :rfmt_ethernet_src, # Inferred.
          'ethDst'     => :rfmt_ethernet,
          'ethTyp'     => :rfmt_ethertype,
          'ipSrc'      => :rfmt_ipv4_src,     # Inferred.
          'ipDst'      => :rfmt_ipv4,
          'ipProto'    => :rfmt_nw_proto,
          'nwProto'    => :rfmt_nw_proto,
          'port'       => :rfmt_in_port,      # Inferred.
          'switch'     => :dp_id,
          'tcpSrcPort' => :rfmt_tp_src,
          'tcpDstPort' => :rfmt_tp_dst,
          'vlanId'     => :rfmt_vlan_id,      # Inferred (vandervecken).
          'vlanPcp'    => :rfmt_vlan_pcp      # Inferred.
        }

        def self.treat(hash)
          hash[:rfmt_ipv4_src] = parsed_ipv4(hash[:rfmt_ipv4_src]) unless hash[:rfmt_ipv4_src].nil?
          hash[:rfmt_ipv4] = parsed_ipv4(hash[:rfmt_ipv4]) unless hash[:rfmt_ipv4].nil?
          hash
        end
      end
    end
  end
end
