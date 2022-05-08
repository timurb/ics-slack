class Scheduler
  attr :period
  attr_reader :name

  def initialize(name, period=5, logger=Logger.new(STDOUT), &block)
    @name = name
    @block = block
    @period = normalize_period(period)
    @logger = logger
    @logger.debug "Next schedule for #{name}: #{next_run}"
  end

  def run(current_time=Time.now)
    @logger.debug "Waiting for scheduled time for #{name}: #{next_run}"
    if next_run <= current_time
      run!(current_time)
    end
  end

  def run!(current_time=Time.now)
    @logger.info "Running #{name}"
    @block.call(name)
    @last_run = Time.now
    @logger.debug "Next schedule for #{name}: #{next_run}"
  end

  def last_run
    @last_run ||= Time.new(1970)
  end

  def next_run
    last_run + period
  end

  private

  def normalize_period(period)
    period * 60
  end
end
