# frozen_string_literal: true

#
# Detects if time is within monitored range
#
class Detector
  attr_reader :range

  def initialize(range)
    @range = normalize_range(range)
  end

  def detect(time)
    current_time + range > time
  end

  private

  def normalize_range(range)
    range * 60
  end

  def current_time
    Time.now
  end
end
