# frozen_string_literal: true

require 'spec_helper'
require 'dry/files'
require 'ical_feed'

describe IcalFeed do
  let(:ical_feed) { IcalFeed.new('dummy') }
  let(:files) { Dry::Files.new }
  let(:fixture) { files.read(files.join(File.dirname(__FILE__), 'fixtures', 'ics.xml')) }

  before do
    allow(ical_feed).to receive(:raw).and_return fixture
  end

  it 'parses ICS' do
    ical_feed.parse
    expect(ical_feed.ics).not_to be_nil
    expect(ical_feed.ics.events.count).to be_eql 37
  end

  it 'proccesses ICS and keeps only events in future' do
    ical_feed.parse
    ical_feed.process
    expect(ical_feed.events.count).to be_eql 33
  end
end
