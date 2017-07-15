require 'spec_helper'

describe Havox::RIB do
  let(:route)   { FactoryGirl.build :route }
  let(:options) { Hash(vm_names: %w(foo_vm bar_vm)) }

  subject { Havox::RIB.new(options) }

  before :each do
    allow(Havox::RouteFlow).to receive(:ribs).with(
      %w(foo_vm bar_vm), anything
    ).and_return([route])
  end

  describe '.new' do
    it 'creates a RIB object encapsulating routes' do
      expect(subject.routes).to include(route)
    end
  end
end
