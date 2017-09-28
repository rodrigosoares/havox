require 'spec_helper'

describe Havox::Node do
  describe '.new' do
    it 'instantiates a topology node object' do
      attribs = { type: 'host', ip: '10.0.0.1' }
      new_node = Havox::Node.new('h1', attribs)
      expect(new_node.name).to eq('h1')
      expect(new_node.attributes).to include(ip: '10.0.0.1')
      expect(new_node.type).to be(:host)
    end
  end

  describe '#host?' do
    let(:node) { FactoryGirl.build(:node, :host) }

    it 'evaluates to true if the node is a host' do
      expect(node).to be_host
    end
  end

  describe '#switch?' do
    let(:node) { FactoryGirl.build(:node, :switch) }

    it 'evaluates to true if the node is a switch' do
      expect(node).to be_switch
    end
  end
end
