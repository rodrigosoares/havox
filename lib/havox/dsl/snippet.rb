module Havox
  module DSL
    class Snippet
      attr_reader :attributes

      MERLIN_DIC = {
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

      DEFAULT_REGEX_PATH = '.*'

      def initialize(action, attributes = {})
        @action = action
        @attributes = attributes
      end

      def method_missing(name, *args, &block)
        @attributes[name] = args.first
      end

      def to_statement(regex_path = DEFAULT_REGEX_PATH, qos = nil)
        fields = @attributes.map { |k, v| "#{MERLIN_DIC[k]} = #{v}" }
        predicate = fields.join(' and ')
        qos_str = qos.nil? ? '' : " at #{qos}"
        "#{predicate} -> #{regex_path}#{qos_str};"
      end
    end
  end
end
