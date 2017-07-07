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
    it 'returns a hash of RouteFlow containers with their parsed routes' do
      allow(subject).to receive(:fetch).with('foo_vm').and_return([raw_route])
      allow(subject).to receive(:fetch).with('bar_vm').and_return([])
      routes = subject.ribs(['foo_vm', 'bar_vm'])
      expect(routes['foo_vm'].map(&:protocol)).to include(route.protocol)
      expect(routes['foo_vm'].map(&:network)).to include(route.network)
      expect(routes['foo_vm'].map(&:via)).to include(route.via)
      expect(routes['foo_vm'].map(&:interface)).to include(route.interface)
      expect(routes['foo_vm'].map(&:timestamp)).to include(route.timestamp)
      expect(routes['bar_vm']).to be_empty
    end
  end
end
