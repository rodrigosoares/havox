require 'spec_helper'

describe Havox::OpenFlow10::RouteFlow::Matches do
  describe '::FIELDS' do
    it 'keeps a dictionary of Merlin to RouteFlow translations' do
      fields_dic = subject::FIELDS
      expect(fields_dic['ethSrc']).to eq(:ethernet_src)
      expect(fields_dic['ethDst']).to eq(:ethernet)
      expect(fields_dic['ethTyp']).to eq(:ethertype)
      expect(fields_dic['ipSrc']).to eq(:ipv4_src)
      expect(fields_dic['ipDst']).to eq(:ipv4)
      expect(fields_dic['ipProto']).to eq(:nw_proto)
      expect(fields_dic['nwProto']).to eq(:nw_proto)
      expect(fields_dic['port']).to eq(:in_port)
      expect(fields_dic['switch']).to eq(:dp_id)
      expect(fields_dic['tcpSrcPort']).to eq(:tp_src)
      expect(fields_dic['tcpDstPort']).to eq(:tp_dst)
      expect(fields_dic['vlanId']).to eq(:vlan_id)
      expect(fields_dic['vlanPcp']).to eq(:vlan_pcp)
    end
  end

  describe '.treat' do
    let :ovs_hash do
      Hash[ipv4_src: '100000001', ipv4: '100000002']
    end

    it 'treats the matches hash data to be readable by RouteFlow' do
      treated_hash = subject.treat(ovs_hash)
      expect(treated_hash[:ipv4_src]).to eq('5.245.225.1')
      expect(treated_hash[:ipv4]).to eq('5.245.225.2')
    end
  end
end
