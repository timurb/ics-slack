# frozen_string_literal: true

require 'faraday'
require 'faraday/net_http'
require 'icalendar'
require_relative 'event'
require 'rrule'

#
# A class to pull ICal feed, parse it and generate list of upcoming events
#
class IcalFeed
  attr_reader :url
  attr_reader :status
  attr_reader :response
  attr_reader :raw
  attr_reader :ics
  attr_reader :events

  def initialize(url)
    @url = url
  end

  # Fetch ICal feed from remote server
  def fetch
    response = Faraday.get(url)
    @status = response.status
    @response = response
    @raw = response.body
  end

  def parse
    @ics = Icalendar::Calendar.parse(raw).first
  end

  # Process ICal feed into array of Events
  def process   # rubocop:disable Metrics/MethodLength
    @events =
      ics.events.map do |event|
        event.parent = nil
        next_event = time_for(event)
        next unless next_event

        Event.new(
          uid: event.uid,
          title: event.summary,
          time: next_event,
          description: event.description,
          location: event.location,
          url: event.url
        )
      end.compact # rubocop:disable Style/MethodCalledOnDoEndBlock
  end

  private

  def time_for(event)
    if event.rrule.empty?
      event.dtstart.to_time
    else
      rrule = RRule.parse(event.rrule.first.value_ical, dtstart: event.dtstart)
      rrule.from(current_time, limit: 1).first
    end
  end

  def current_time
    Time.now
  end
end
