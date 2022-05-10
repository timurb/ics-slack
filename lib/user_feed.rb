# frozen_string_literal: true

require_relative 'notifier'

#
# This class holds the feed of Events and Notifications for events for the user
# It doesn't have any knowledge of feed URLs (yet?)
class UserFeed
  attr_reader :events

  def initialize
    @events = []
    @notifications = []
  end

  def check(period)
    events.each { |event| notify(event, period) }
  end

  def notify(event, period) # rubocop:disable Metrics/MethodLength
    period = normalize_range(period)
    return unless event.within?(seconds: period, from: current_time)
    return unless recent_notifications(event, period).empty?

    notification = Event.new(
      uid: event.uid,
      title: event.title,
      time: current_time,
      description: event.description,
      location: event.location,
      url: event.url
    )

    @notifications << notification
    Notifier.perform_async(notification.to_dto)
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
      ###FIXME probably this is no longer needed if we don't need idempotency of adding events to the feed 
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

  private

  def recent_notifications(event, period)
    @notifications.find_all do |notification|
      notification.uid == event.uid && notification.within?(seconds: period, till: current_time)
    end
  end

  def normalize_range(range)
    range * 60
  end

  def current_time
    Time.now
  end
end
