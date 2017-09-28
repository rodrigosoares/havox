require 'spec_helper'

describe Havox::Edge do
  let(:host)   { FactoryGirl.build(:node, :host) }
  let(:switch) { FactoryGirl.build(:node, :switch) }

  describe '.new' do
    it 'instantiates a topology edge object' do
      attribs = { src_port: '1', dst_port: '2', cost: '3', capacity: '5Gbps' }
      new_edge = Havox::Edge.new(switch, host, attribs)
      expect(new_edge.from.name).to eq(switch.name)
      expect(new_edge.to.name).to eq(host.name)
      expect(new_edge.attributes).to include(attribs)
    end
  end
end
