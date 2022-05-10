require 'spec_helper'
require 'detector'

RSpec.describe Detector do
  let(:detector) { Detector.new(15) }
  let(:current_time) { Time.now }

  before do
    allow(detector).to receive(:current_time).and_return(current_time)
  end

  context 'event is within defined range from now' do
    let(:target_time) { current_time + 5 * 60 }

    it 'returns true' do
      expect(detector.detect(target_time)).to be_truthy
    end
  end

  context 'event is outside defined range from now' do
    let(:target_time) { current_time + 30 * 60 }

    it 'returns true' do
      expect(detector.detect(target_time)).to be_falsy
    end
  end
end
