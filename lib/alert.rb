require 'date'

# This class can be raised if necessary
#
class Alert < StandardError
  attr_reader :message, :payload, :time

  def initialize(message, payload = nil)
    @message = message
    @payload = payload
    @time = DateTime.now
  end
end

class HighTrafficAlert < Alert
  def initialize(hits:)
    super("High traffic generated an alert - hits = #{hits}, triggered at #{DateTime.now}")
  end
end

class EndHighTrafficAlert < Alert
  def initialize
    super("High traffic alert recovered, triggered at #{DateTime.now}")
  end
end
