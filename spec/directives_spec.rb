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

  describe '#render' do
    let(:sw_host_map) { Hash['s1' => %w(h1), 's2' => %w(h2), 's3' => %w(h3), 's4' => %w(h4)] }
    let(:topology) { double('topology') }

    before :each do
      allow(topology).to receive(:hosts_by_switch).and_return(sw_host_map)
      allow(topology).to receive(:host_names).and_return(sw_host_map.values.flatten)
    end

    it 'translates the attributes into a Merlin policy block' do
      expect(directive.render(topology, 'min(1 Mbps)')).to include(
        'foreach (s, d): cross({ h2; h3; h4 }, { h1 })',
        'tcpDstPort = 80 -> .* s1 at min(1 Mbps);'
      )
    end

    context 'when rendering a specific block for each orchestration directive' do
      let(:exit_dir)       { FactoryGirl.build(:directive, :exit) }
      let(:tunnel_dir)     { FactoryGirl.build(:directive, :tunnel) }
      let(:circuit_dir)    { FactoryGirl.build(:directive, :circuit) }
      let(:circuit_dir_wc) { FactoryGirl.build(:directive, :circuit, switches: [:s1, '.*', :s2]) }

      it 'renders from the :exit directive' do
        expect(exit_dir.render(topology, 'min(1 Mbps)')).to include(
          'foreach (s, d): cross({ h2; h3; h4 }, { h1 })',
          'tcpDstPort = 80 -> .* s1 at min(1 Mbps);'
        )
      end

      it 'renders from the :tunnel directive' do
        expect(tunnel_dir.render(topology, 'min(1 Mbps)')).to include(
          'foreach (s, d): cross({ h1 }, { h2 })',
          'tcpDstPort = 80 -> .* s2 at min(1 Mbps);'
        )
      end

      it 'renders from the :circuit directive' do
        expect(circuit_dir.render(topology, 'min(1 Mbps)')).to include(
          'foreach (s, d): cross({ h1 }, { h2 })',
          'tcpDstPort = 80 -> s1 s3 s4 s2 at min(1 Mbps);'
        )
      end

      it 'renders from the :circuit directive with wildcarded path' do
        expect(circuit_dir_wc.render(topology, 'min(1 Mbps)')).to include(
          'foreach (s, d): cross({ h1 }, { h2 })',
          'tcpDstPort = 80 -> s1 .* s2 at min(1 Mbps);'
        )
      end
    end
  end
end
