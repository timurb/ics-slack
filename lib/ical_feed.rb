# frozen_string_literal: true

require 'faraday'
require 'faraday/net_http'
require 'icalendar'
require_relative 'event'

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

  def fetch
    response = Faraday.get(url)
    @status = response.status
    @response = response
    @raw = response.body
  end

  def parse
    @ics = Icalendar::Calendar.parse(raw).first
  end

  def process
    @events = ics.events.map do |event|
      event.parent = nil
      Event.new(uuid: event.uid, title: event.summary, description: event.description, time: time_for(event))
    end
  end

  private

  def time_for(event)
    event.dtstart.to_time       ###FIXME: doesn't work for recurring eventys
  end
end