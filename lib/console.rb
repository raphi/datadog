require_relative 'utils'

# Draw a simple dashboard on the output with some useful informations
# PS: you can dynamically resize your console (up to a certain point...)
#
class Console
  H_SEP = '-'.freeze
  V_SEP = '|'.freeze

  def initialize(event_queue:)
    @queue = event_queue

    # Clear screen at initialization
    clear_screen
  end

  def refresh_screen
    clear_screen

    display_alerts
    print "\n"
    draw_line
    display_stats
    draw_line
    display_top
    draw_line
    display_last_logs
    draw_line
  end

  # Display alerts in color on the top
  #
  def display_alerts
    @queue.alerts.each do |alert|
      clear_line

      message = alert.kind_of?(HighTrafficAlert) ? alert.message.red : alert.message.green
      print "[ALERT]\t#{message}\n"
    end
  end

  # Display general stats and threshold window stats
  #
  def display_stats
    draw "Total hits:  %d"               % @queue.total_hits
    draw "Hits  (past %isc): %d"         % [@queue.threshold, @queue.current_hits]
    draw "High traffic alerts:       %d" % @queue.high_traffic_alerts
    draw_eol

    draw "Total bytes: %s (Avg: ~%s)"    % [@queue.total_bytes.as_readable_bytes, @queue.avg_bytes.as_readable_bytes]
    draw "Bytes (past %isc): %s "        % [@queue.threshold, @queue.current_bytes.as_readable_bytes]
    draw "High traffic ended alerts: %s" % @queue.end_of_high_traffic_alerts
    draw_eol
  end

  # Display some top three infos
  #
  def display_top(n: 3)
    draw "Top #{n} sections:"
    draw "Top #{n} HTTP status:"
    draw "Top #{n} IPs:"
    draw_eol
    clear_line

    sections = @queue.top_sections.first(n)
    statuses = @queue.top_status.first(n)
    ips = @queue.top_ips.first(n)

    n.times do |index|
      clear_line

      section, section_hits = sections[index]
      status, status_hits = statuses[index]
      ip, ip_hits = ips[index]

      draw "    %-19s %-10s" % [section.to_s.empty? ? '/' : section, section_hits]
      status.nil? ? (draw '') : (draw "    #{status}  #{status_hits}" % [status, status_hits])
      ip.nil? ? (draw '') : (draw "    %-16s %s" % [ip, ip_hits])

      draw_eol
    end
  end

  # Display common log line
  #
  def display_last_logs(n: 7)
    @queue.last(n).each do |common_log|
      printf "%s %-#{columns - 4}s %s" % [V_SEP, common_log.to_s, V_SEP]
    end
  end

  private

  # Print a line of whitespace to clear out previous artefacts
  #
  def clear_line
    print "\r%s\r" % ' ' * columns
  end

  # Clear screen cross plateform compatible
  #
  def clear_screen
    system "clear" or system "cls"
  end

  # Get current terminal width
  #
  def columns
    IO.console.winsize.last
  end

  # Draw a section (1 column of 3)
  #
  def draw(text)
    printf "%s %-#{(columns / 3) - 5}s " % [V_SEP, text]
  end

  # Draw a full line of separators
  #
  def draw_line
    print H_SEP * columns
  end

  # Draw the far right separator
  #
  def draw_eol
    print "\r\e[#{columns - 1}C#{V_SEP}\n"
  end
end
