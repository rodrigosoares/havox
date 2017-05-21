require 'spec_helper'

describe Havox::OpenFlow10::OVS::Matches do
  describe '::FIELDS' do
    it 'keeps a dictionary of Merlin to OpenVSwitch translations' do
      fields_dic = subject::FIELDS
      expect(fields_dic['ethSrc']).to eq(:dl_src)
      expect(fields_dic['ethDst']).to eq(:dl_dst)
      expect(fields_dic['ethTyp']).to eq(:dl_type)
      expect(fields_dic['ipSrc']).to eq(:nw_src)
      expect(fields_dic['ipDst']).to eq(:nw_dst)
      expect(fields_dic['ipProto']).to eq(:nw_proto)
      expect(fields_dic['nwProto']).to eq(:nw_proto)
      expect(fields_dic['port']).to eq(:in_port)
      expect(fields_dic['switch']).to eq(:dp_id)
      expect(fields_dic['tcpSrcPort']).to eq(:tp_src)
      expect(fields_dic['tcpDstPort']).to eq(:tp_dst)
      expect(fields_dic['vlanId']).to eq(:dl_vlan)
      expect(fields_dic['vlanPcp']).to eq(:dl_vlan_pcp)
    end
  end

  describe '.treat' do
    let :ovs_hash do
      Hash[nw_src: '100000001', nw_dst: '100000002']
    end

    it 'treats the matches hash data to be readable by OpenVSwitch' do
      treated_hash = subject.treat(ovs_hash)
      expect(treated_hash[:nw_src]).to eq('5.245.225.1')
      expect(treated_hash[:nw_dst]).to eq('5.245.225.2')
    end
  end
end
