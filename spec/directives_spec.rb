require 'spec_helper'

describe Havox::DSL::Directive do
  let(:directive) { FactoryGirl.build(:directive, attrs: { destination_port: 80 }) }

  describe '#instance_eval' do
    it 'calls an overridden #method_missing to get the attributes from a block' do
      attrs_block = proc { source_port 20 }
      directive.instance_eval(&attrs_block)
      expect(directive.attributes).to include(source_port: 20)
    end
  end

  describe '#to_block' do
    it 'translates the attributes into a Merlin policy block' do
      expect(directive.to_block(%w(h1 h2 h3), %w(h4), 'min(1 Mbps)')).to include(
        'foreach (s, d): cross({ h1; h2; h3 }, { h4 })',
        'tcpDstPort = 80 -> .* s1 at min(1 Mbps);'
      )
    end
  end
end
