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

  describe '#hosts' do
    it 'returns only host nodes' do
      types_of_returned_nodes = subject.hosts.map(&:type).uniq
      expect(types_of_returned_nodes).to contain_exactly(:host)
    end
  end

  describe '#host_names' do
    it 'returns the parsed host names' do
      expect(subject.host_names).to contain_exactly('h1', 'h2')
    end
  end

  describe '#ips_by_switch' do
    it 'returns an hash of switches and their IP addresses' do
      expect(subject.ips_by_switch).to eq({ 's1' => '10.0.0.3' })
    end
  end

  describe '#hosts_by_switch' do
    it 'returns an hash of switches and their connected hosts array' do
      expect(subject.hosts_by_switch).to eq({ 's1' => ['h1', 'h2']})
    end
  end

  describe '#border_switches' do
    it 'returns only switches connected to hosts' do
      expect(subject.border_switches.length).to eq(1)
      expect(subject.border_switches.sample).to be_instance_of(Havox::Node)
      expect(subject.border_switches.sample.name).to eq('s1')
    end
  end
end
