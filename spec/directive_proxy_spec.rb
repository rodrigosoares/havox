require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::DSL::DirectiveProxy do
  subject { Havox::DSL::DirectiveProxy.new }

  before(:each) { Havox::Network.reset! }

  describe '#exit' do
    it 'guides the matching packets from all sources to the chosen exit switch' do
      exit_proc = proc { exit(:s1) { source_port 20 } }
      subject.instance_eval(&exit_proc)
      directive = Havox::Network.directives.sample
      expect(directive).to be_instance_of(Havox::DSL::Directive)
      expect(directive.instance_variable_get(:@type)).to be(:exit)
      expect(directive.switches).to contain_exactly(:s1)
      expect(directive.attributes).to include(source_port: 20)
    end
  end

  describe '#drop' do
    it 'discards the matching packets' do
      pending 'Not yet implemented'
      drop_block = proc { drop { source_port 20 } }
      directive = Havox::Network.directives.sample
      expect(directive).to be_instance_of(Havox::DSL::Directive)
      expect(directive.instance_variable_get(:@type)).to be(:drop)
      expect(directive.attributes).to include(source_port: 20)
    end
  end

  describe '#tunnel' do
    it 'guides the matching packets from a single source to the chosen exit switch' do
      tunnel_proc = proc { tunnel(:s2, :s4) { source_port 20 } }
      subject.instance_eval(&tunnel_proc)
      directive = Havox::Network.directives.sample
      expect(directive).to be_instance_of(Havox::DSL::Directive)
      expect(directive.instance_variable_get(:@type)).to be(:tunnel)
      expect(directive.switches).to match_array([:s2, :s4])
      expect(directive.attributes).to include(source_port: 20)
    end
  end

  describe '#circuit' do
    it 'guides the matching packets through a predefined path' do
      circuit_proc = proc { circuit(:s1, :s4, :s2) { source_port 20 } }
      subject.instance_eval(&circuit_proc)
      directive = Havox::Network.directives.sample
      expect(directive).to be_instance_of(Havox::DSL::Directive)
      expect(directive.instance_variable_get(:@type)).to be(:circuit)
      expect(directive.switches).to match_array([:s1, :s4, :s2])
      expect(directive.attributes).to include(source_port: 20)
    end
  end

  describe '#associate' do
    it 'associates a routing instance to an underlying switch' do
      associate_block = proc { associate :rfvmA, :s1 }
      subject.instance_eval(&associate_block)
      expect(Havox::Network.devices).to include('rfvmA' => 's1')
    end
  end

  describe '#topology' do
    before :each do
      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:exists?).with('/topo.dot').and_return(true)
      allow(File).to receive(:read).with('/topo.dot').
        and_return(topology_file_content)
    end
    it 'defined the network topology file' do
      topology_block = proc { topology '/topo.dot' }
      subject.instance_eval(&topology_block)
      expect(Havox::Network.topology).to be_instance_of(Havox::Topology)
    end

    it 'raises an error if the topology file does not exist' do
      topology_block = proc { topology '/invalid.dot' }
      expect { subject.instance_eval(&topology_block) }.
        to raise_error(Havox::Network::InvalidTopology)
    end
  end
end
