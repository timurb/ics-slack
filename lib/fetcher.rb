require_relative 'scheduler'

class Fetcher
  attr_reader :name
  attr_reader :scheduler
  attr_reader :iterations

  def initialize(name)
    @name = name
    @iterations = 0
    @scheduler = Scheduler.new(name, 1) do
      bump
      puts "Iteration #{iterations}"
    end
  end

  def run
    scheduler.run
  end

  def bump
    @iterations += 1
  end
end
