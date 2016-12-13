require 'date'
require_relative 'alert'
require_relative 'stats'

class EventQueue
  include Stats

  attr_reader :alerts, :hits_alert_threshold, :threshold

  # Events are considered old after 2 minutes by default
  #
  def initialize(hits_alert_threshold: 500, threshold: 120)
    super()

    @alerts = []
    @queue = []
    @hits_alert_threshold = hits_alert_threshold
    @threshold = threshold
  end

  # Add event to the internal queue
  #
  def push(event:)
    super

    @queue << event
  end

  # Allow access to the internal queue
  #
  def last(n)
    @queue.last(n)
  end

  # Scan the array up until we find a valid element (still in the @threshold bucket)
  # Delete all old events from the queue and return it
  # This could be called internally after each event push.
  # However, it is more efficient to let the outside timer control it.
  #
  def flush
    oldest_event_index = nil
    old_events_date_limit = old_events_date

    @queue.each_with_index do |element, index|
      # We know next events are fresher so no need to scan the rest of the queue
      break if element.date >= old_events_date_limit

      oldest_event_index = index
    end

    # Trigger an alert checks once old events are flushed
    # This is better here than after each `push` to smooth on average the threshold
    check_alerts

    # Return an empty array or old events while updating the internal queue
    oldest_event_index.nil? ? [] : @queue.slice!(0..oldest_event_index)
  end

  private

  # Check if the number of events in the current pipeline window is over the set threshold.
  # Generates an alert only once before it goes back under the threshold.
  #
  def check_alerts
    hits = @queue.size

    if hits >= @hits_alert_threshold && (@alerts.empty? || @alerts.last.kind_of?(EndHighTrafficAlert))
      @alerts << HighTrafficAlert.new(hits: hits)
    elsif hits < @hits_alert_threshold && @alerts.last.kind_of?(HighTrafficAlert)
      @alerts << EndHighTrafficAlert.new
    end
  end

  # Return the limit date from which events are consider out of the window
  # @threshold must be in seconds
  #
  def old_events_date
    # 86400 seconds == 1 day
    DateTime.now - @threshold / 86400.0
  end
end
