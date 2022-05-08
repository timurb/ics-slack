require_relative 'scheduler'
# require_relative 'event'
require 'faraday'
require 'faraday/net_http'
require 'icalendar'
require 'ostruct'

class Fetcher
  attr_reader :name
  attr_reader :scheduler
  attr_reader :url
  attr_reader :calendar

  def initialize(name, url, period=1, logger=Logger.new(STDOUT)) ##FIXME period
    @name = name
    @url = url
    @logger = logger
    @calendar = nil
    @events = []

    @scheduler = Scheduler.new(name, period, logger) do
      ics = get_ics(url)
      populate_events(ics.events)
      logger.info("#{@events.count} events available")
    end
  end

  def run
    scheduler.run
  end

  def get_ics(url)
    response = Faraday.get(url)
    if response.status != 200
      @logger.warning "HTTP response #{response.status} when retrieving #{name}"
    end

    ics = Icalendar::Calendar.parse(response.body).first
  end

  def populate_events(events)
    events.each do |event|
      event.parent = nil
      index = @events.find_index { |old_event| old_event.uid == event.uid }
      if index
        @events[index] = event
      else
        @events.push event
      end
    end
  end
end
