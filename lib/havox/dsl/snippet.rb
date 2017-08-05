module Havox
  module DSL
    class Snippet
      attr_reader :attributes

      PREDICATE_DIC = {
        destination_ip:   'ipDst',
        destination_mac:  'ethDst',
        destination_port: 'tcpDstPort',
        ethernet_type:    'ethTyp',
        in_port:          'port',
        ip_protocol:      'ipProto',
        source_ip:        'ipSrc',
        source_mac:       'ethSrc',
        source_port:      'tcpSrcPort',
        vlan_id:          'vlanId',
        vlan_priority:    'vlanPcp'
      }

      def initialize(action)
        @action = action
        @attributes = {}
      end

      def method_missing(name, *args, &block)
        @attributes[name] = args.first
      end

      def to_predicate
        attrs_array = @attributes.map do |field, value|
          merlin_field = PREDICATE_DIC[field]
          "#{merlin_field} = #{value}"
        end
        attrs_array.join(' and ')
      end
    end
  end
end
