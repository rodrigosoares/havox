require 'spec_helper'

describe Havox::Command do
  describe '.show_ip_route' do
    it 'builds a protocol RIB show command' do
      returned_cmd = subject.show_ip_route('foo_vm', :bgp)
      expected_cmd = "sudo lxc-attach -n foo_vm -- /usr/bin/vtysh -c 'show ip route bgp'"
      expect(returned_cmd).to eq(expected_cmd)
    end
  end

  describe '.toggle_daemon' do
    it 'builds a remote daemon activating command' do
      returned_cmd = subject.toggle_daemon('foo_vm', :bgpd)
      expected_cmd = "sudo lxc-attach -n foo_vm -- /bin/sed -i 's/bgpd=no/bgpd=yes/' /etc/quagga/daemons"
      expect(returned_cmd).to eq(expected_cmd)
    end

    it 'builds a remote daemon deactivating command' do
      returned_cmd = subject.toggle_daemon('foo_vm', :bgpd, false)
      expected_cmd = "sudo lxc-attach -n foo_vm -- /bin/sed -i 's/bgpd=yes/bgpd=no/' /etc/quagga/daemons"
      expect(returned_cmd).to eq(expected_cmd)
    end
  end

  describe '.toggle_service' do
    it 'builds a remote service toggling command' do
      returned_cmd = subject.toggle_service('foo_vm', '/path/to/service', :restart)
      expected_cmd = 'sudo lxc-attach -n foo_vm -- /path/to/service restart'
      expect(returned_cmd).to eq(expected_cmd)
    end
  end

  describe '.copy_conf_files' do
    it 'builds a daemon configuration file setting command' do
      returned_cmd = subject.copy_conf_files('foo_vm', :bgpd)
      expected_cmd = 'sudo lxc-attach -n foo_vm -- /bin/cp /usr/share/doc/quagga/examples/bgpd.conf.sample /etc/quagga/bgpd.conf'
      expect(returned_cmd).to eq(expected_cmd)
    end
  end

  describe '.backup' do
    it 'builds a backup command' do
      returned_cmd = subject.backup('foo_vm', '/path/to/file')
      expected_cmd = 'sudo lxc-attach -n foo_vm -- /bin/cp /path/to/file /path/to/file.old'
      expect(returned_cmd).to eq(expected_cmd)
    end
  end

  describe '.chown' do
    it 'builds a file owner changing command' do
      returned_cmd = subject.chown('foo_vm', 'bar', 'bar', '/path/to/file')
      expected_cmd = 'sudo lxc-attach -n foo_vm -- /bin/chown bar:bar /path/to/file'
      expect(returned_cmd).to eq(expected_cmd)
    end
  end

  describe '.chmod' do
    it 'builds a file permissions changing command' do
      returned_cmd = subject.chmod('foo_vm', 776, '/path/to/file')
      expected_cmd = 'sudo lxc-attach -n foo_vm -- /bin/chmod 776 /path/to/file'
      expect(returned_cmd).to eq(expected_cmd)
    end
  end

  describe '.compile' do
    let(:config) { Havox.configuration }

    it 'builds a Merlin policy compilation command' do
      returned_cmd = subject.compile('/path/to/topo', '/path/to/policy')
      expected_cmd = "GUROBI_HOME=\"#{config.gurobi_path}\" PATH=\"${PATH}:${GUROBI_HOME}/bin\" " \
                     'LD_LIBRARY_PATH="${GUROBI_HOME}/lib" GRB_LICENSE_FILE="${GUROBI_HOME}/gurobi.lic" ' \
                     "#{config.merlin_path}/Merlin.native -topo /path/to/topo /path/to/policy -verbose"
      expect(returned_cmd).to eq(expected_cmd)
    end
  end
end
