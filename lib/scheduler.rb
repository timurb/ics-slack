# frozen_string_literal: true

require 'logger'

#
# Scheduler runs the specified block every time you invoke scheduler.run
# but no more often than period passed at init time
#
# The intent is to call several scheduler.run periodically using cron or sidekiq
# and still to be able to control the run frequency
#
class Scheduler
  attr_reader :name, :period

  def initialize(name, period = 5, logger = Logger.new($stdout), &block)
    @name = name
    @block = block
    @period = normalize_period(period)
    @logger = logger
    @logger.debug("Next schedule for #{name}: #{next_run}")
  end

  def run
    @logger.debug("Waiting for scheduled time for #{name}: #{next_run}")
    return unless next_run <= current_time

    run!
  end

  def run!
    @logger.info("Running #{name}")
    @block.call(name)
    @last_run = current_time
    @logger.debug("Next schedule for #{name}: #{next_run}")
  end

  def last_run
    @last_run ||= oldest_time
  end

  def next_run
    last_run + period
  end

  def current_time
    Time.now
  end

  private

  def oldest_time
    Time.new(1970)
  end

  def normalize_period(period)
    period * 60
  end
end
