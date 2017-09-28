require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::DSL::DirectiveProxy do
  subject { Havox::DSL::DirectiveProxy.new }

  before(:each) { Havox::Network.reset! }

  describe '#balance' do
    it 'parses a balance directive block' do
      balance_block = proc { balance(:s1) { source_port 20 } }
      subject.instance_eval(&balance_block)
      directive = Havox::Network.directives.sample
      expect(directive).to be_instance_of(Havox::DSL::Directive)
      expect(directive.instance_variable_get(:@type)).to be(:balance)
      expect(directive.switch).to be(:s1)
      expect(directive.attributes).to include(source_port: 20)
    end
  end

  # describe '#drop' do
  #   it 'parses a drop directive block' do
  #     pending 'Yet to be implemented'
  #     expect(true).to be(false)
  #   end
  # end

  describe '#topology' do
    before :each do
      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:exists?).with('/topo.dot').and_return(true)
      allow(File).to receive(:read).with('/topo.dot').
        and_return(topology_file_content)
    end
    it 'sets the network topology' do
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
