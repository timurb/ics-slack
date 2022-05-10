# rubocop:disable Layout/RedundantLineBreak
require 'spec_helper'
require 'event'

RSpec.describe Event do
  let(:current_time) { Time.now }
  let(:past_event1) { Event.new(uid: SecureRandom.uuid, title: 'title1', time: current_time - 100) }
  let(:past_event2) { Event.new(uid: SecureRandom.uuid, title: 'title2', time: current_time - 400) }
  let(:future_event1) { Event.new(uid: SecureRandom.uuid, title: 'title1', time: current_time + 100) }
  let(:future_event2) { Event.new(uid: SecureRandom.uuid, title: 'title2', time: current_time + 400) }

  it 'detects events in the past' do
    expect(
      past_event1.within?(seconds: 300, till: current_time)
    ).to be_truthy

    expect(
      past_event2.within?(seconds: 300, till: current_time)
    ).to be_falsy

    expect(
      future_event1.within?(seconds: 300, till: current_time)
    ).to be_falsy
  end

  it 'detects events in the future' do
    expect(
      future_event1.within?(seconds: 300, from: current_time)
    ).to be_truthy

    expect(
      future_event2.within?(seconds: 300, from: current_time)
    ).to be_falsy

    expect(
      past_event1.within?(seconds: 300, from: current_time)
    ).to be_falsy
  end

  it 'raises exception when trying to use both past and future' do
    expect {
      past_event1.within?(seconds: 300, till: current_time, from: current_time)
    }.to raise_error(ArgumentError)

    expect {
      past_event1.within?(seconds: 300)
    }.to raise_error(ArgumentError)
  end
end
