class ICSFeed
  attr_reader :url
  attr :period

  def initialize(url, period=5, logger=Logger.new(STDOUT))
    @url = url
    @period = normalize_period(period)
    @logger = logger
  end

  def fetch(current_time=Time.now)
    @logger.info "Waiting for time to fetch #{@url}: #{next_fetch}"
    if next_fetch < current_time
      fetch!(current_time)
    end
  end

  def fetch!(current_time=Time.now)
    @logger.info "Fetching iCal feed from url #{@url}"
    @last_fetch = Time.now
    @logger.info "Next fetch for #{@url}: #{next_fetch}"
  end

  def last_fetch
    @last_fetch ||= Time.new(1970)
  end

  def next_fetch
    last_fetch + period
  end

  private

  def normalize_period(period)
    period * 60
  end
end
