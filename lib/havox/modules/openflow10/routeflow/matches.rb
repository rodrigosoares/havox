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
          hash[:rfmt_ethertype] = hash[:rfmt_ethertype].to_i unless hash[:rfmt_ethertype].nil?
          hash[:rfmt_ipv4_src]  = parsed_ipv4(hash[:rfmt_ipv4_src]) unless hash[:rfmt_ipv4_src].nil?
          hash[:rfmt_ipv4]      = parsed_ipv4(hash[:rfmt_ipv4]) unless hash[:rfmt_ipv4].nil?
          hash[:rfmt_nw_proto]  = hash[:rfmt_nw_proto].to_i unless hash[:rfmt_nw_proto].nil?
          hash[:rfmt_in_port]   = hash[:rfmt_in_port].to_i unless hash[:rfmt_in_port].nil?
          hash[:rfmt_tp_src]    = hash[:rfmt_tp_src].to_i unless hash[:rfmt_tp_src].nil?
          hash[:rfmt_tp_dst]    = hash[:rfmt_tp_dst].to_i unless hash[:rfmt_tp_dst].nil?
          hash[:rfmt_vlan_id]   = hash[:rfmt_vlan_id].to_i unless hash[:rfmt_vlan_id].nil?
          hash
        end
      end
    end
  end
end
