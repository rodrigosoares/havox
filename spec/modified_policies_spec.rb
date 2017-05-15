require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::ModifiedPolicy do
  describe '.new' do
    let(:policy_file)     { StringIO.new(policy_file_content) }
    let(:topology_file)   { StringIO.new(topology_file_content) }
    let(:mod_policy_file) { StringIO.new }

    before :each do
      allow(File).to receive(:read).with('/path/to/topology.dot').and_return(topology_file.string)
      allow(File).to receive(:read).with('/path/to/policy.mln').and_return(policy_file.string)
      allow(Tempfile).to receive(:open).with(['policy', '.mln']).and_yield(mod_policy_file)
      allow_any_instance_of(StringIO).to receive(:path).and_return('/tmp/policy_mod.mln')
      @mp = Havox::ModifiedPolicy.new('/path/to/topology.dot', '/path/to/policy.mln')
    end

    it 'copies the policy file to a temporary modified file' do
      expect(@mp.path).to eq('/tmp/policy_mod.mln')
      expect(mod_policy_file.string).not_to be_empty
    end

    it 'appends a policy for the ICMP protocol' do
      expect(mod_policy_file.string).to include('ethTyp = 2048 and ipProto = 1 -> .* at min(100 Mbps);')
    end

    it 'appends a policy for the ARP protocol' do
      expect(mod_policy_file.string).to include('ethTyp = 2054 -> .* at min(100 Mbps);')
    end
  end
end
