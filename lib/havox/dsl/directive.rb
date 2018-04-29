module Havox
  module DSL
    class Directive
      attr_reader :switches, :attributes

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

      def initialize(type, switches, attributes = {})
        @type = type
        @switches = switches
        @attributes = attributes
      end

      def method_missing(name, *args, &block)
        @attributes[name] = args.first
      end

      def render(topology, qos = nil)
        case @type
        when :exit
          switch = @switches.first.to_s
          src_hosts = topology.host_names - topology.hosts_by_switch[switch]
          dst_hosts = topology.hosts_by_switch[switch]
        else
          src_hosts = topology.host_names
          dst_hosts = topology.host_names
        end
        "#{foreach_code(src_hosts, dst_hosts)}\n  #{to_statement(qos)}\n"
      end

      private

      def to_statement(qos)
        fields = @attributes.map { |k, v| "#{MERLIN_DIC[k]} = #{treated(v, k)}" }
        predicate = fields.join(' and ')
        qos_str = qos.nil? ? '' : " at #{qos}"
        "#{predicate} -> #{regex_path}#{qos_str};"
      end

      def format_hosts(host_names)
        "{ #{host_names.join('; ')} }"
      end

      def foreach_code(src_hosts, dst_hosts)
        src_hosts_str = format_hosts(src_hosts)
        dst_hosts_str = format_hosts(dst_hosts)
        "foreach (s, d): cross(#{src_hosts_str}, #{dst_hosts_str})"
      end

      def treated(value, field)
        case field
        when :source_ip      then netmask_removed(value)
        when :destination_ip then netmask_removed(value)
        else value
        end
      end

      def netmask_removed(ip)
        IPAddr.new(ip).to_s
      end

      def regex_path
        ".* #{@switches.join(' ')}".strip
      end
    end
  end
end
