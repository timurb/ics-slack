# frozen_string_literal: true

require_relative 'detector'
require_relative 'notifier'

class UserFeed

  attr_reader :events

  def initialize
    @events = []
  end

  def check(period)
    detector = Detector.new(period)

    events.each do |event|
      Notifier.perform_async(event.to_dto) if detector.detect(event.time) ###FIXME: serialize to JSON
    end
  end

  def add(event)
    if events.find_index { |elem| elem.uid == event.uid }
      ###FIXME
      # This supposed to be deduplication of events but really here we have a different problem:
      # Yandex Calendar returns all events in a series as several events with the same UID:
      #   - one event with RRULE
      #   - multiple events without RRULE (with the same UID)
      # Probably we should capture all of them but when producing notification
      # check for several events with the same UID and produce only a single one
      events
    else
      events << event
    end
  end

  def add_from_ical(ical)
    ical.events.each do |event|
      add(event)
    end
  end
end