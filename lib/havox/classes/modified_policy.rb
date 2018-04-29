module Havox
  class ModifiedPolicy
    attr_reader :path

    def initialize(topology_file_path, policy_file_path)
      @topology = Havox::Topology.new(topology_file_path)
      @original_policy_file_path = policy_file_path
      @path = nil
      append_basic_policies
    end

    private

    def arp_policy
      Havox::DSL::Directive.new(nil, [], ethernet_type: 2054).
        render(@topology, 'min(100 Mbps)')
    end

    def icmp_policy
      Havox::DSL::Directive.new(nil, [], ethernet_type: 2048, ip_protocol: 1).
        render(@topology, 'min(100 Mbps)')
    end

    def policies
      [icmp_policy, arp_policy]
    end

    def append_basic_policies
      policy_file_string = File.read(@original_policy_file_path)
      basename = File.basename(@original_policy_file_path, '.mln')
      Tempfile.open([basename, '.mln']) do |tmp|
        tmp.puts "#{policy_file_string}\n"
        tmp.puts policies.join("\n")
        @path = tmp.path
      end
    end
  end
end
