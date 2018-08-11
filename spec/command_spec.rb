require 'spec_helper'

describe Havox::Command do
  describe '.show_ip_route' do
    it 'builds a protocol RIB show command' do
      @returned_cmd = subject.show_ip_route('foo_vm', :bgp)
      @expected_cmd = "sudo lxc-attach -n foo_vm -- /usr/bin/vtysh -c 'show ip route bgp'"
    end
  end

  describe '.arp_awk' do
    it 'builds an ARP table command pipelined to Grep and AWK to print IPs and their MACs' do
      @returned_cmd = subject.arp_awk('foo_vm', 'eth0')
      @expected_cmd =
        "sudo lxc-attach -n foo_vm -- /usr/sbin/arp -ni eth0 | grep eth0 | awk '{print $1, $3}'"
    end
  end

  describe '.vtysh_run' do
    it 'builds an arbitrary user command to be sent to the VMs' do
      @returned_cmd = subject.vtysh_run('foo_vm', 'ip route')
      @expected_cmd = "sudo lxc-attach -n foo_vm -- /usr/bin/vtysh -c 'ip route'"
    end
  end

  describe '.compile' do
    let(:config) { Havox.configuration }

    it 'builds a Merlin policy compilation command' do
      @returned_cmd = subject.compile('/path/to/topo', '/path/to/policy')
      @expected_cmd = "GUROBI_HOME=\"#{config.gurobi_path}\" PATH=\"${PATH}:${GUROBI_HOME}/bin\" " \
                     'LD_LIBRARY_PATH="${GUROBI_HOME}/lib" GRB_LICENSE_FILE="${GUROBI_HOME}/gurobi.lic" ' \
                     "#{config.merlin_path}/Merlin.native -topo /path/to/topo /path/to/policy -verbose"
    end
  end

  after(:each) { expect(@returned_cmd).to eq(@expected_cmd) }
end
