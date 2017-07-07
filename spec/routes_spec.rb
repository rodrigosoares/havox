require 'spec_helper'

describe Havox::Route do
  let(:route)     { FactoryGirl.build :route }
  let(:raw_route) { 'O>* 10.0.0.0/24 [110/20] via 40.0.0.2, eth2, 03:41:18' }

  describe '.new' do
    it 'parses a raw route coming from RouteFlow' do
      new_route = Havox::Route.new(raw_route)
      expect(new_route.via).to eq('40.0.0.2')
      expect(new_route.network).to eq('10.0.0.0/24')
      expect(new_route.protocol).to eq(:ospf)
      expect(new_route.interface).to eq('eth2')
      expect(new_route.timestamp).to eq('03:41:18')
      expect(new_route.best).to be(true)
      expect(new_route.fib).to be(true)
    end
  end
end
