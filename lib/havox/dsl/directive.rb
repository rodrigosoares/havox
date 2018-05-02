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

      MERLIN_RENDERABLE = [:exit, :tunnel, :circuit]

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
        when :exit then exit_policy(topology, qos)
        when :tunnel then tunnel_policy(topology, qos)
        when :circuit then circuit_policy(topology, qos)
        else generic_policy(topology, qos)
        end
      end

      def renderable?
        MERLIN_RENDERABLE.include?(@type)
      end

      def raw_matches(switch_id)
        raw_attrs = @attributes.map { |k, v| "#{MERLIN_DIC[k]} = #{v}" }
        "switch = #{switch_id} and #{raw_attrs.join(' and ')}"
      end

      private

      def exit_policy(topology, qos)
        switch = @switches.first.to_s
        src_hosts = topology.host_names - topology.hosts_by_switch[switch]
        dst_hosts = topology.hosts_by_switch[switch]
        regex_path = ".* #{switch}"
        merlin_policy(src_hosts, dst_hosts, regex_path, qos)
      end

      def tunnel_policy(topology, qos)
        src_hosts = topology.hosts_by_switch[@switches.first.to_s]
        dst_hosts = topology.hosts_by_switch[@switches.last.to_s]
        regex_path = ".* #{@switches.last}"
        merlin_policy(src_hosts, dst_hosts, regex_path, qos)
      end

      def circuit_policy(topology, qos)
        src_hosts = topology.hosts_by_switch[@switches.first.to_s]
        dst_hosts = topology.hosts_by_switch[@switches.last.to_s]
        regex_path = @switches.join(' ')
        merlin_policy(src_hosts, dst_hosts, regex_path, qos)
      end

      def generic_policy(topology, qos)
        src_hosts = dst_hosts = topology.host_names
        regex_path = '.*'
        merlin_policy(src_hosts, dst_hosts, regex_path, qos)
      end

      def merlin_policy(src_hosts, dst_hosts, regex_path, qos)
        "#{foreach(src_hosts, dst_hosts)}\n  #{statement(regex_path, qos)}\n"
      end

      def statement(regex_path, qos)
        matches = @attributes.map { |k, v| "#{MERLIN_DIC[k]} = #{treated(v, k)}" }
        predicate = matches.join(' and ')
        qos_str = qos.nil? ? '' : " at #{qos}"
        "#{predicate} -> #{regex_path}#{qos_str};"
      end

      def host_arg(host_names)
        "{ #{host_names.join('; ')} }"
      end

      def foreach(src_hosts, dst_hosts)
        "foreach (s, d): cross(#{host_arg(src_hosts)}, #{host_arg(dst_hosts)})"
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
    end
  end
end
