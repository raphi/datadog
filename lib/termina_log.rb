#!/usr/bin/env ruby

require 'io/console'
require_relative 'common_log_parser'
require_relative 'console'
require_relative 'event_queue'

class TerminaLog

  def initialize(hits_alert_threshold: 10000, screen_refresh: 1, threshold: 120)
    @event_queue = EventQueue.new(hits_alert_threshold: hits_alert_threshold.to_i, threshold: threshold.to_i)
    @console = Console.new(event_queue: @event_queue)
    @screen_refresh = screen_refresh.to_i
  end

  # Start: - the daemon listening to inputs (filename or piped in) and parsing it
  #        - the UI thread refreshing console outputs
  #
  def start
    # Thread this to allow screen refresh in parallel of STDIN input stream
    # being consummed or waiting, without blocking it
    Thread.new do
      every_n_seconds(@screen_refresh) { flush_and_refresh }
    end

    # Stream taking filenames or STDIN
    ARGF.each_line do |line|
      common_log = CommonLogParser.parse(line)
      @event_queue.push(event: common_log) if common_log.valid?
    end

    # Refresh screen with latest information before exiting
    flush_and_refresh
  rescue Interrupt => e
    # Catch Crtl + C signal to exit program gracefully
    flush_and_refresh
    exit
  end

  private

  def flush_and_refresh
    @event_queue.flush()
    @console.refresh_screen()
  end

  def every_n_seconds(n)
    loop do
      before = Time.now
      yield
      interval = n - (Time.now - before)
      sleep(interval) if interval > 0
    end
  end

end
