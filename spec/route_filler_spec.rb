require 'spec_helper'

describe Havox::RouteFiller do
  let(:leader_route) { 'O>* 30.0.0.0/24 [110/20] via 20.0.0.3, eth3, 07:18:25' }
  let(:abbrev_route) { '  *                      via 50.0.0.1, eth4, 07:18:25' }
  let(:raw_routes)   { [leader_route, abbrev_route] }

  subject { Havox::RouteFiller.new(raw_routes) }

  describe '.new' do
    it 'fills abbreviated routes with info from leader routes' do
      expect(subject.filled_routes).to contain_exactly(
        'O>* 30.0.0.0/24 [110/20] via 20.0.0.3, eth3, 07:18:25',
        'O * 30.0.0.0/24 [110/10] via 50.0.0.1, eth4, 07:18:25'
      )
    end
  end
end
