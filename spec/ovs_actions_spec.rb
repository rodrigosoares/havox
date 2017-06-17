require 'spec_helper'

describe Havox::OpenFlow10::OVS::Actions do
  let(:mln_output)              { Hash[action: 'Output', arg_a: '1', arg_b: ''] }
  let(:mln_enqueue)             { Hash[action: 'Enqueue', arg_a: '2', arg_b: '2'] }
  let(:mln_set_field_vlan_id)   { Hash[action: 'SetField', arg_a: 'vlan', arg_b: '2'] }
  let(:mln_set_field_vlan_none) { Hash[action: 'SetField', arg_a: 'vlan', arg_b: '<none>'] }
  let(:mln_set_field_port)      { Hash[action: 'SetField', arg_a: 'port', arg_b: '80'] }
  let(:mln_unknown)             { Hash[action: 'Unknown', arg_a: '0', arg_b: ''] }
  let(:mln_actions)             { [mln_output, mln_enqueue, mln_set_field_vlan_id, mln_set_field_vlan_none] }

  describe '.treat' do
    it 'translates actions from Merlin format to OpenFlow 1.0 format' do
      of_actions = subject.treat(mln_actions)
      expect(of_actions).to include({ action: :output, arg_a: '1', arg_b: nil })
      expect(of_actions).to include({ action: :enqueue, arg_a: '2', arg_b: '2' })
      expect(of_actions).to include({ action: :strip_vlan, arg_a: nil, arg_b: nil })
      expect(of_actions).to include({ action: :mod_vlan_vid, arg_a: '2', arg_b: nil })
    end

    it 'switches Enqueue for Output if specified' do
      of_actions = subject.treat(mln_actions, { output: true })
      expect(of_actions).to include({ action: :output, arg_a: '2', arg_b: nil })
      expect(of_actions.map { |a| a[:action]}).not_to include(:enqueue)
    end

    it 'raises an error if an unpredicted action is found' do
      expect { subject.treat([mln_unknown]) }.to raise_error(Havox::UnknownAction)
    end

    it 'raises an error if a set unknown field action is found' do
      expect { subject.treat([mln_set_field_port]) }.to raise_error(Havox::UnknownAction)
    end
  end
end
