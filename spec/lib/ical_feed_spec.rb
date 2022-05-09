# frozen_string_literal: true

require 'spec_helper'
require 'dry/files'
require 'ical_feed'

describe IcalFeed do
  let(:feeder) { IcalFeed.new('dummy') }
  let(:files) { Dry::Files.new }
  let(:fixture) { files.read(files.join(File.dirname(__FILE__), 'fixtures', 'ics.xml')) }

  before do
    allow(feeder).to receive(:raw).and_return fixture
  end

  it 'parses ICS' do
    feeder.parse
    expect(feeder.ics).not_to be_nil
    expect(feeder.ics.events.count).to be_eql 37
  end

  it 'processes ICS' do
    feeder.parse
    feeder.process
    expect(feeder.events.count).to be_eql 37
  end
end
