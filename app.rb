require 'sidekiq-scheduler'
require_relative 'lib/scheduler'
require_relative 'lib/fetcher'

class ICSFetcher
  include Sidekiq::Worker

  def perform
    $ics.run
  end
end

$ics = Fetcher.new('test')
$ics.run
