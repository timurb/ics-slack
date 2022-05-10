require 'sidekiq'

class Notifier
  include Sidekiq::Job

  def perform(event)
    pp event
  end
end