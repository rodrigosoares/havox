require 'spec_helper'

describe Havox::ARPTable do
  let(:mac_1)       { '00:00:00:00:00:01' }
  let(:table)       { FactoryGirl.build :arp_table, :populated }
  let(:empty_table) { FactoryGirl.build :arp_table }

  describe '#lookup' do
    it 'returns the port associated to the given MAC address' do
      expect(table.lookup(mac_1)).to eq(1)
    end

    it 'returns nil if the MAC address has no port associated' do
      expect(empty_table.lookup(mac_1)).to be(nil)
    end
  end

  describe '#learn!' do
    let(:mac_2) { '00:00:00:00:00:02' }

    it 'creates a new entry' do
      table.learn!(mac_2, 2)
      expect(table.lookup(mac_2)).to eq(2)
    end

    it 'updates an existing entry' do
      table.learn!(mac_1, 2)
      expect(table.lookup(mac_1)).to eq(2)
    end
  end

  describe '#age!' do
    it 'deletes aged entries' do
      allow_any_instance_of(Havox::ARPEntry).to receive(:aged?).and_return(true)
      table.age!
      expect(table.instance_variable_get(:@table)).to be_empty
    end
  end
end
