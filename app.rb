require 'sidekiq-scheduler'
require_relative 'lib/scheduler'

class ICSFetcher
  include Sidekiq::Worker

  def perform
    $ics.run
  end
end

$ics = Scheduler.new('test', 1) do
  puts "Block is run"
end

$ics.run
