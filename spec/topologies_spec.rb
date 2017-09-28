require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::Topology do
  before :each do
    allow(File).to receive(:read).with('/path/to/topology.dot').
      and_return(topology_file_content)
    @topology = Havox::Topology.new('/path/to/topology.dot')
  end

  subject { @topology }

  describe '.new' do
    it 'instantiates a parsed topology for a target .dot file' do
      expect(subject.nodes).not_to be_empty
      expect(subject.edges).not_to be_empty
      expect(subject.nodes.sample).to be_instance_of(Havox::Node)
      expect(subject.edges.sample).to be_instance_of(Havox::Edge)
    end
  end

  describe '#host_names' do
    it 'returns the parsed host names' do
      expect(subject.host_names).to contain_exactly('h1', 'h2')
    end
  end

  describe '#switch_ips' do
    it 'returns an hash of switches and their IP addresses' do
      expect(subject.switch_ips).to eq({ 's1' => '10.0.0.3' })
    end
  end

  describe '#switch_hosts' do
    it 'returns an hash of switches and their connected hosts array' do
      expect(subject.switch_hosts).to eq({ 's1' => ['h1', 'h2']})
    end
  end
end
