require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::RouteFlow do
  let(:route)          { FactoryGirl.build :route }
  let(:raw_route)      { 'O>* 10.0.0.0/24 [110/20] via 40.0.0.2, eth2, 03:41:18' }
  let(:ssh_connection) { double('connection') }

  describe '.fetch' do
    it 'returns the parsed RIB of a specific RouteFlow container' do
      allow(Net::SSH).to receive(:start).and_yield(ssh_connection)
      allow(ssh_connection).to receive(:exec!).and_return(container_ospf_routes_response)
      raw_routes = subject.fetch('foo_vm', :ospf)
      expect(raw_routes.size).to be(11)
      expect(raw_routes).to include(raw_route)
    end
  end

  describe '.ribs' do
    it 'returns an array of parsed RouteFlow routes' do
      allow(subject).to receive(:fetch).with('foo_vm').and_return([raw_route])
      allow(subject).to receive(:fetch).with('bar_vm').and_return([])
      routes = subject.ribs(['foo_vm', 'bar_vm'])
      foo_vm_routes = routes.select { |route| route.router.eql?('foo_vm') }
      bar_vm_routes = routes.select { |route| route.router.eql?('bar_vm') }
      expect(foo_vm_routes.map(&:protocol)).to include(route.protocol)
      expect(foo_vm_routes.map(&:network)).to include(route.network)
      expect(foo_vm_routes.map(&:via)).to include(route.via)
      expect(foo_vm_routes.map(&:interface)).to include(route.interface)
      expect(foo_vm_routes.map(&:timestamp)).to include(route.timestamp)
      expect(bar_vm_routes).to be_empty
    end
  end

  describe '.arp_table' do
    it 'returns a map of IP addresses to MAC addresses' do
      allow(Net::SSH).to receive(:start).and_yield(ssh_connection)
      allow(ssh_connection).to receive(:exec!).and_return(container_arp_response)
      expect(subject.arp_table(['foo_vm'], 'eth0')).to eq({
        '192.168.1.10' => 'a0:a0:a0:a0:a0:a0'
      })
    end
  end
end
