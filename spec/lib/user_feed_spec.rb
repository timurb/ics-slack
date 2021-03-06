require 'spec_helper'
require 'user_feed'
require 'notifier'
require 'sidekiq/testing'

RSpec.describe UserFeed do
  let(:user_feed) { UserFeed.new }
  let(:current_time) { Time.now }

  before do
    allow_any_instance_of(UserFeed).to receive(:current_time).and_return(current_time)
  end

  context 'creation of user feed' do
    let(:ical_feed) { IcalFeed.new('dummy') }
    let(:ical_feed2) { IcalFeed.new('dummy2') }
    let(:files) { Dry::Files.new }
    let(:fixture) { files.read(files.join(File.dirname(__FILE__), 'fixtures', 'ics.xml')) }
    let(:fixture2) { files.read(files.join(File.dirname(__FILE__), 'fixtures', 'ics2.xml')) }

    before do
      allow(ical_feed).to receive(:raw).and_return fixture
      ical_feed.parse
      ical_feed.process
    end

    it 'creates an event' do
      event = Event.new(uid: SecureRandom.uuid, title: 'title', time: current_time)
      user_feed.add(event)
      expect(user_feed.events.size).to be_eql 1
      event = Event.new(uid: SecureRandom.uuid, title: 'title', time: current_time)
      user_feed.add(event)
      expect(user_feed.events.size).to be_eql 2
    end

    it 'removes duplicates' do
      uid = SecureRandom.uuid
      event = Event.new(uid: uid, title: 'title', time: current_time)
      user_feed.add(event)
      expect(user_feed.events.size).to be_eql 1
      event = Event.new(uid: uid, title: 'title', time: current_time)
      user_feed.add(event)
      expect(user_feed.events.size).to be_eql 1
    end

    it 'pulls data from ICal feed' do
      user_feed.add_from_ical(ical_feed)

      expect(user_feed.events.size).to be_eql 28 ###FIXME: see comment regarding deduplication in UserFeed
    end

    it 'removes duplicates from ICal feed' do
      user_feed.add_from_ical(ical_feed)
      user_feed.add_from_ical(ical_feed)

      expect(user_feed.events.size).to be_eql 28 ###FIXME: see comment regarding deduplication in UserFeed
    end

    it 'combines data from add and ICal feed' do
      event = Event.new(uid: SecureRandom.uuid, title: 'title', time: current_time)
      user_feed.add(event)
      user_feed.add_from_ical(ical_feed)

      expect(user_feed.events.size).to be_eql 29 ###FIXME: see comment regarding deduplication in UserFeed
    end

    it 'combines data from several ICal feeds' do
      allow(ical_feed2).to receive(:raw).and_return fixture2
      ical_feed2.parse
      ical_feed2.process
      event = Event.new(uid: SecureRandom.uuid, title: 'title', time: current_time)

      user_feed.add_from_ical(ical_feed)
      user_feed.add(event)
      user_feed.add_from_ical(ical_feed2)

      expect(user_feed.events.size).to be_eql 57
    end
  end

  context 'sending out notifications' do
    let(:future_event1) { Event.new(uid: SecureRandom.uuid, title: 'title1', time: current_time + 5*60) }
    let(:future_event2) { Event.new(uid: SecureRandom.uuid, title: 'title2', time: current_time + 30*60) }
    let(:future_event3) { Event.new(uid: SecureRandom.uuid, title: 'title3', time: current_time + 15*60) }
    let(:past_event1) { Event.new(uid: SecureRandom.uuid, title: 'title4', time: current_time - 5*60) }

    before do
      Notifier.clear
    end

    it 'emits message on upcoming event' do
      user_feed.add(future_event1)
      user_feed.add(future_event2)
      user_feed.add(future_event3)
      user_feed.check(10)
      expect(Notifier.jobs.size).to be_eql 1
    end

    it 'emits message on several upcoming event' do
      user_feed.add(future_event1)
      user_feed.add(future_event2)
      user_feed.add(future_event3)
      user_feed.check(20)
      expect(Notifier.jobs.size).to be_eql 2
    end

    it 'doesnt emit message on past event' do
      user_feed.add(future_event1)
      user_feed.add(past_event1)
      user_feed.check(10)
      expect(Notifier.jobs.size).to be_eql 1
    end

    it 'emits message inside a time frame only once' do
      user_feed.add(future_event1)
      user_feed.check(10)
      user_feed.check(10)
      expect(Notifier.jobs.size).to be_eql 1
    end

    context 'notifications for different time ranges' do
      it 'emits several messages inside a folding time frames' do
        allow_any_instance_of(UserFeed).to receive(:current_time).and_return(current_time)
        user_feed.add(future_event1)
        user_feed.check(5)

        # simulate passing 4 minutes 1 seconds
        allow_any_instance_of(UserFeed).to receive(:current_time).and_return(current_time + 4 * 60 + 1)

        user_feed.check(1)
        expect(Notifier.jobs.size).to be_eql 2
      end
    end
  end
end
