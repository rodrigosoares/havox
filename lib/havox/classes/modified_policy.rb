module Havox
  class ModifiedPolicy
    attr_reader :path

    def initialize(topology_file_path, policy_file_path)
      @topology_file_path = topology_file_path
      @original_policy_file_path = policy_file_path
      @path = nil
      append_basic_policies
    end

    private

    ARP_POLICY  = 'ethTyp = 2054 -> .* at min(100 Mbps);'
    ICMP_POLICY = 'ethTyp = 2048 and ipProto = 1 -> .* at min(100 Mbps);'
    POLICIES    = [ICMP_POLICY, ARP_POLICY]
    HOSTS_REGEX = /(?<host>\w+)\s*\[.*type\s*=\s*host.*\];/i

    def append_basic_policies
      policy_file_string = File.read(@original_policy_file_path)
      basename = File.basename(@original_policy_file_path, '.mln')
      Tempfile.open([basename, '.mln']) do |tmp|
        tmp.puts "#{policy_file_string}\n"
        tmp.puts basic_policies(parsed_hosts)
        @path = tmp.path
      end
    end

    def parsed_hosts
      hosts = []
      File.read(@topology_file_path).each_line do |l|
        match_data = l.match(HOSTS_REGEX)
        hosts << match_data[:host] unless match_data.nil?
      end
      hosts
    end

    def basic_policies(hosts_array)
      hosts_str = "{ #{hosts_array.join('; ')} }"
      result = []
      POLICIES.each { |policy| result << "#{policy_code(policy, hosts_str)}" }
      result.join("\n")
    end

    def foreach_snippet(hosts_str)
      "foreach (s, d): cross(#{hosts_str}, #{hosts_str})\n"
    end

    def policy_code(protocol_policy, hosts_str)
      "#{foreach_snippet(hosts_str)}  #{protocol_policy}\n"
    end
  end
end
