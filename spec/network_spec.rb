require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::Network do
  let(:route_1)    { FactoryGirl.build(:route, :direct, router: 'rfvmA', network: '172.31.1.0/24') }
  let(:route_2)    { FactoryGirl.build(:route, :direct, router: 'rfvmB', network: '172.31.2.0/24') }
  let(:bgp_route)  { FactoryGirl.build(:route, :bgp, network: '200.156.0.0/16', via: '172.31.1.100') }

  let :definition_block do
    proc do
      topology 'topo.dot'
      exit(:s1) { destination_port 80 }
    end
  end

  before :each do
    allow(Havox::RouteFlow).to receive(:ribs).and_return([route_1, route_2, bgp_route])
    allow(File).to receive(:exists?).with('topo.dot').and_return(true)
    allow(File).to receive(:read).with('topo.dot').
      and_return(topo_2h_2sw_content)
    subject.define(&definition_block)
  end

  describe '.directives' do
    it 'returns the directive objects from the DSL' do
      directive = subject.directives.sample
      expect(directive).to be_instance_of(Havox::DSL::Directive)
      expect(directive.switch).to be(:s1)
      expect(directive.attributes).to include(destination_port: 80)
    end
  end

  describe '.rib' do
    it 'returns the network RIB' do
      expect(subject.rib).to be_instance_of(Havox::RIB)
    end
  end

  describe '.devices' do
    let :new_block do
      proc do
        topology 'topo.dot'
        associate :rfvmA, :s1
        associate :rfvmB, :s2
        exit(:s1) { destination_port 80 }
      end
    end

    context 'returns the associations between routers and switches' do
      it 'by association directives' do
        subject.define(&new_block)
        expect(subject.devices).to include('rfvmA' => 's1', 'rfvmB' => 's2')
      end

      it 'by OSPF inference, otherwise' do
        expect(subject.devices).to include('rfvmA' => 's1', 'rfvmB' => 's2')
      end
    end
  end

  describe '.topology' do
    it 'returns the parsed topology from the DSL' do
      expect(subject.topology).to be_instance_of(Havox::Topology)
      expect(subject.topology.host_names).to contain_exactly('h1', 'h2')
      expect(subject.topology.switch_hosts).to include('s1' => ['h1'], 's2' => ['h2'])
      expect(subject.topology.switch_ips).to include(
        's1' => '172.31.1.1',
        's2' => '172.31.2.1',
      )
    end
  end

  describe '.reachable' do
    it 'lists all network addresses known' do
      expect(subject.reachable).to include('200.156.0.0/16')
    end

    it 'returns empty if the RIB is not defined' do
      subject.instance_variable_set(:@rib, nil)
      expect(subject.reachable).to be_empty
    end
  end

  describe '.transcompile' do
    it 'transcompiles the directive objects into Merlin code' do
      directive = subject.directives.sample
      expect(subject.transcompile).to include(directive.to_block(%w(h2), %w(h1)))
    end
  end

  describe '.reset!' do
    it 'resets all Havox Network instance variables to their initial values' do
      subject.reset!
      expect(subject.directives).to be_empty
      expect(subject.devices).to be_empty
      expect(subject.rib).to be_nil
      expect(subject.topology).to be_nil
    end
  end
end
