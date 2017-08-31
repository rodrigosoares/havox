require 'spec_helper'

describe Havox::RIB do
  let(:network)   { '172.50.0.0/16' }
  let(:route)     { FactoryGirl.build :route }
  let(:bgp_route) { FactoryGirl.build :route, :bgp, network: network }
  let(:options)   { Hash(vm_names: %w(foo_vm bar_vm)) }

  subject { Havox::RIB.new(options) }

  before :each do
    allow(Havox::RouteFlow).to receive(:ribs).with(
      %w(foo_vm bar_vm), anything
    ).and_return([route, bgp_route])
  end

  describe '.new' do
    it 'creates a RIB object encapsulating routes' do
      expect(subject.routes).to include(route)
    end
  end

  describe '#routes_to' do
    it 'returns the known routes to the given IP address and protocol' do
      target_ip = '172.50.1.100'
      expect(subject.routes_to(target_ip)).to contain_exactly(bgp_route)
    end
  end
end
