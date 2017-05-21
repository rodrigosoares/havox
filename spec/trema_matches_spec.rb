require 'spec_helper'

describe Havox::OpenFlow10::Trema::Matches do
  describe '::FIELDS' do
    it 'keeps a dictionary of Merlin to Trema translations' do
      fields_dic = subject::FIELDS
      expect(fields_dic['ethSrc']).to eq(:source_mac_address)
      expect(fields_dic['ethDst']).to eq(:destination_mac_address)
      expect(fields_dic['ethTyp']).to eq(:ether_type)
      expect(fields_dic['ipSrc']).to eq(:source_ip_address)
      expect(fields_dic['ipDst']).to eq(:destination_ip_address)
      expect(fields_dic['ipProto']).to eq(:ip_protocol)
      expect(fields_dic['nwProto']).to eq(:ip_protocol)
      expect(fields_dic['port']).to eq(:in_port)
      expect(fields_dic['switch']).to eq(:dp_id)
      expect(fields_dic['tcpSrcPort']).to eq(:transport_source_port)
      expect(fields_dic['tcpDstPort']).to eq(:transport_destination_port)
      expect(fields_dic['vlanId']).to eq(:vlan_vid)
      expect(fields_dic['vlanPcp']).to eq(:vlan_priority)
    end
  end

  describe '.treat' do
    let :trema_hash do
      Hash[ether_type: '2048', source_ip_address: '100000001',
        destination_ip_address: '100000002', ip_protocol: '6',
        in_port: '1', transport_source_port: '30000',
        transport_destination_port: '443', vlan_vid: '1', vlan_priority: '1']
    end

    it 'treats the matches hash data to be readable by Trema' do
      treated_hash = subject.treat(trema_hash)
      expect(treated_hash[:ether_type]).to be_a(Integer)
      expect(treated_hash[:source_ip_address]).to eq('5.245.225.1')
      expect(treated_hash[:destination_ip_address]).to eq('5.245.225.2')
      expect(treated_hash[:ip_protocol]).to be_a(Integer)
      expect(treated_hash[:in_port]).to be_a(Integer)
      expect(treated_hash[:transport_source_port]).to be_a(Integer)
      expect(treated_hash[:transport_destination_port]).to be_a(Integer)
      expect(treated_hash[:vlan_vid]).to be_a(Integer)
      expect(treated_hash[:vlan_priority]).to be_a(Integer)
    end
  end
end
