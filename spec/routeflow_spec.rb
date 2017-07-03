require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::RouteFlow do
  let(:raw_route)      { 'O>* 10.0.0.0/24 [110/20] via 40.0.0.2, eth2, 03:41:18' }
  let(:ssh_connection) { double('connection') }

  describe '.fetch' do
    it 'returns the parsed RIB of a specific RouteFlow container' do
      allow(Net::SSH).to receive(:start).and_yield(ssh_connection)
      allow(ssh_connection).to receive(:exec!).and_return(container_ospf_routes_response)
      expect(subject.fetch('foo_vm', :ospf).size).to be(11)
      expect(subject.fetch('foo_vm', :ospf)).to include(raw_route)
    end
  end

  describe '.ribs' do
    it 'returns a hash of RouteFlow containers with their parsed routes' do
      pending 'Write this test'
      expect(true).to be false
    end
  end

  # describe '.toggle_services' do
  #   it 'activates all the services listed in the configuration file' do
  #     pending 'Write this test'
  #     expect(true).to be false
  #   end
  #
  #   it 'deactivates all the services listed in the configuration file' do
  #     pending 'Write this test'
  #     expect(true).to be false
  #   end
  # end
end
