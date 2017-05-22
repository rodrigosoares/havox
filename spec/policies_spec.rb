require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::Policies do
  let(:rule)           { FactoryGirl.build :rule }
  let(:merlin_path)    { "#{Havox.configuration.merlin_path}" }
  let(:ssh_connection) { double('connection') }

  describe '.run' do
    it 'outputs user-issued command results' do
      allow(Net::SSH).to receive(:start).and_yield(ssh_connection)
      allow(ssh_connection).to receive(:exec!).and_return('result')
      expect(subject.run('command')).to eq('result')
    end
  end

  describe '.compile' do
    it 'returns a set of parsed rules generated by Merlin' do
      allow(subject).to receive(:run).and_return(merlin_response)
      rules = subject.compile('/foo.dot', 'foo.mln')
      expect(rules.map(&:dp_id)).to include(rule.dp_id)
      expect(rules.map(&:matches)).to include(rule.matches)
      expect(rules.map(&:actions)).to include(rule.actions)
    end

    it 'returns an empty set if Merlin generates no rules' do
      allow(subject).to receive(:run).and_return(merlin_response(true))
      rules = subject.compile('/foo.dot', 'foo.mln')
      expect(rules).to be_empty
    end

    it 'raises an error if Merlin encounters an exception' do
      allow(subject).to receive(:run).and_return(merlin_error_response)
      expect { subject.compile('/foo.dot', 'foo.mln') }.to raise_error(Havox::Merlin::ParsingError)
    end
  end

  describe '.compile!' do
    let(:local_topology_file)      { '/local/path/to/file.dot' }
    let(:local_policy_file)        { '/local/path/to/file.mln' }
    let(:remote_topology_file)     { "#{merlin_path}/examples/file.dot" }
    let(:remote_policy_file)       { "#{merlin_path}/examples/file.mln"}
    let(:remote_dst_topology_file) { '/remote/path/to/file.dot' }
    let(:remote_dst_policy_file)   { '/remote/path/to/file.mln' }

    before(:each) do
      allow(subject).to receive(:upload!).and_return(true)
      allow(subject).to receive(:compile).and_return([rule])
    end

    it 'uploads and compiles the files at the default remote path' do
      expect(subject).to receive(:compile).with(remote_topology_file, remote_policy_file, false)
      subject.compile!(local_topology_file, local_policy_file)
    end

    it 'uploads and compiles the files at an arbitrary remote path' do
      options = { dst: '/remote/path/to/' }
      expect(subject).to receive(:compile).with(remote_dst_topology_file, remote_dst_policy_file, false)
      subject.compile!(local_topology_file, local_policy_file, options)
    end
  end

  describe '.upload!' do
    before(:each) do
      allow(Net::SSH).to receive(:start).and_yield(ssh_connection)
      allow(ssh_connection).to receive(:scp).and_return(double)
    end

    it 'uploads a file to a Merlin subfolder' do
      allow(ssh_connection.scp).to receive(:upload!).with('/foo.dot', "#{merlin_path}/examples/")
      expect(subject.upload!('/foo.dot')).to be true
    end

    it 'uploads a file to an arbitrary path' do
      allow(ssh_connection.scp).to receive(:upload!).with('/foo.dot', '/destination/path/')
      expect(subject.upload!('/foo.dot', '/destination/path/')).to be true
    end
  end
end
