require 'spec_helper'

describe Havox::Route do
  let(:ospf_route) { FactoryGirl.build :route, router: 'foo_vm' }
  let(:ibgp_route) { FactoryGirl.build :route, :recursive, protocol: :bgp }
  let(:raw_route)  { 'O>* 10.0.0.0/24 [110/20] via 40.0.0.2, eth2, 03:41:18' }
  let(:ospf_str)   { 'OSPF: to 10.0.0.0/24 via 40.0.0.2 in eth2, BEST, FIB route' }
  let(:ibgp_str)   { 'BGP: to 10.0.0.0/24 via 40.0.0.2 in 50.0.0.1, BEST, FIB route' }

  describe '.new' do
    it 'parses a raw route coming from RouteFlow' do
      new_route = Havox::Route.new(raw_route, 'foo_vm')
      expect(new_route.router).to eq('foo_vm')
      expect(new_route.via).to eq('40.0.0.2')
      expect(new_route.network).to eq('10.0.0.0/24')
      expect(new_route.protocol).to eq(:ospf)
      expect(new_route.interface).to eq('eth2')
      expect(new_route.timestamp).to eq('03:41:18')
      expect(new_route.best).to be(true)
      expect(new_route.fib).to be(true)
    end
  end

  describe '#to_s' do
    it 'stringifies the route' do
      expect(ospf_route.to_s).to eq(ospf_str)
      expect(ibgp_route.to_s).to eq(ibgp_str)
    end
  end

  describe '#inspect' do
    it 'stringifies the route with an unique ID and a router name' do
      route_id_str = "Route #{ospf_route.object_id.to_s(16)}"
      router_name_str = "router #{ospf_route.router}"
      expect(ospf_route.inspect).to include(route_id_str, router_name_str, ospf_str)
    end
  end

  describe '#to_h' do
    it 'formats the route into a hash' do
      hash = {
        router: 'foo_vm',
        protocol: :ospf,
        network: '10.0.0.0/24',
        via: '40.0.0.2',
        recursive_via: nil,
        interface: 'eth2',
        timestamp: '03:41:18',
        best: true,
        fib: true
      }
      expect(ospf_route.to_h).to eq(hash)
    end
  end

  describe '#direct?' do
    it 'tells if a route is directly connected' do
      pending 'Implement this test'
      expect(true).to be(false)
    end
  end

  describe '#ospf?' do
    it 'tells if a route is OSPF' do
      pending 'Implement this test'
      expect(true).to be(false)
    end
  end

  describe '#bgp?' do
    it 'tells if a route is BGP' do
      pending 'Implement this test'
      expect(true).to be(false)
    end
  end
end
