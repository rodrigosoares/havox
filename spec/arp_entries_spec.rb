require 'spec_helper'

describe Havox::ARPEntry do
  let(:entry) { FactoryGirl.build :arp_entry }
  subject     { entry }

  describe '#update!' do
    it 'updates entry port and timestamp' do
      subject.update!(2)
      expect(subject.port).to eq(2)
      expect(subject).not_to be_aged
    end
  end
end
