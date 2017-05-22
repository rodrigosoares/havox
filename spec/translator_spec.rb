require 'spec_helper'

describe Havox::Translator do
  subject(:translate) { Havox::Translator.instance }

  describe '#fields_to' do
    context 'calls the fields dictionary' do
      it 'for Trema' do
        expect(subject.fields_to(:trema)).to be_a(Hash)
      end

      it 'for OpenVSwitch' do
        expect(subject.fields_to(:ovs)).to be_a(Hash)
      end
    end

    it 'raises an error if the given translator is unknown' do
      expect { subject.fields_to(:foo) }.to raise_error(Havox::UnknownTranslator)
    end
  end

  describe '#matches_to' do
    let(:trema_hash) { Hash[ip_protocol: '6'] }

    context 'calls the matches hash translation' do
      it 'for Trema' do
        expect(Havox::OpenFlow10::Trema::Matches).to receive(:treat).with(trema_hash)
        subject.matches_to(:trema, trema_hash)
      end

      it 'for OpenVSwitch' do
        expect(Havox::OpenFlow10::OVS::Matches).to receive(:treat).with(trema_hash)
        subject.matches_to(:ovs, trema_hash)
      end
    end

    it 'raises an error if the given translator is unknown' do
      expect { subject.matches_to(:foo, trema_hash) }.to raise_error(Havox::UnknownTranslator)
    end
  end

  describe '#actions_to' do
    let(:mln_action) { Hash[action: 'Output', arg_a: '1', arg_b: ''] }

    context 'calls the action array translation' do
      it 'for Trema' do
        expect(Havox::OpenFlow10::Trema::Actions).to receive(:treat).with([mln_action])
        subject.actions_to(:trema, [mln_action])
      end

      it 'for OpenVSwitch' do
        expect(Havox::OpenFlow10::OVS::Actions).to receive(:treat).with([mln_action])
        subject.actions_to(:ovs, [mln_action])
      end
    end

    it 'raises an error if the given translator is unknown' do
      expect { subject.actions_to(:foo, [mln_action]) }.to raise_error(Havox::UnknownTranslator)
    end
  end
end
