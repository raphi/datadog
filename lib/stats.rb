# Adds simple methods to access common stats.
# Either on the entire pipeline life or the current time window.
#
module Stats
  attr_reader :avg_bytes, :total_hits, :total_bytes

  def initialize
    @avg_bytes = 0
    @total_hits = 0
    @total_bytes = 0
    @ips = Hash.new(0)
    @sections = Hash.new(0)
    @status = Hash.new(0)
  end

  # Extract stats about the event directly
  #
  def push(event:)
    @total_hits += 1
    @total_bytes += event.bytes
    @avg_bytes = @total_bytes ./ @total_hits

    @ips[event.ip] += 1
    @sections[event.section] += 1
    @status["#{event.status.to_s.chars.first}XX"] += 1
  end

  # Aggregation of the number of bytes in the current pipeline (AKA moving threshold time window)
  #
  def current_bytes
    @queue.map(&:bytes).reduce(0, :+)
  end

  # Aggregation of the number of hits in the current pipeline (AKA moving threshold time window)
  #
  def current_hits
    @queue.size
  end

  # Total number of "High traffic" alerts generated
  #
  def high_traffic_alerts
    result = @alerts.select { |alert| alert.kind_of?(HighTrafficAlert) }.count
  end

  # Total number of "End of high traffic" alerts generated
  #
  def end_of_high_traffic_alerts
    @alerts.select { |alert| alert.kind_of?(EndHighTrafficAlert) }.count
  end

  # `dup` in the three methods below is used to avoid concurrency issue when
  # adding new elements to the hash while scanning through it like below
  #
  def top_sections
    @sections.dup.sort_by(&:last).reverse
  end

  def top_status
    @status.dup.sort_by(&:last).reverse
  end

  def top_ips
    @ips.dup.sort_by(&:last).reverse
  end
end
