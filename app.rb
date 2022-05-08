require 'sidekiq-scheduler'
require_relative 'lib/icsfeed'

class ICSFetcher
  include Sidekiq::Worker

  def perform
    $ics.fetch
  end
end

$ics = ICSFeed.new('asd')
