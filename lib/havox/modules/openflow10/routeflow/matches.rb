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
          'ethSrc'     => :ethernet_src, # Inferred.
          'ethDst'     => :ethernet,
          'ethTyp'     => :ethertype,
          'ipSrc'      => :ipv4_src,     # Inferred.
          'ipDst'      => :ipv4,
          'ipProto'    => :nw_proto,
          'nwProto'    => :nw_proto,
          'port'       => :in_port,      # Inferred.
          'switch'     => :dp_id,
          'tcpSrcPort' => :tp_src,
          'tcpDstPort' => :tp_dst,
          'vlanId'     => :vlan_id,      # Inferred (vandervecken).
          'vlanPcp'    => :vlan_pcp      # Inferred.
        }

        def self.treat(hash)
          hash[:ethertype] = hash[:ethertype].to_i unless hash[:ethertype].nil?
          hash[:ipv4_src]  = parsed_ipv4(hash[:ipv4_src]) unless hash[:ipv4_src].nil?
          hash[:ipv4]      = parsed_ipv4(hash[:ipv4]) unless hash[:ipv4].nil?
          hash[:nw_proto]  = hash[:nw_proto].to_i unless hash[:nw_proto].nil?
          hash[:in_port]   = hash[:in_port].to_i unless hash[:in_port].nil?
          hash[:tp_src]    = hash[:tp_src].to_i unless hash[:tp_src].nil?
          hash[:tp_dst]    = hash[:tp_dst].to_i unless hash[:tp_dst].nil?
          hash[:vlan_id]   = hash[:vlan_id].to_i unless hash[:vlan_id].nil?
          hash
        end
      end
    end
  end
end
