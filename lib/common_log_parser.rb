require_relative 'common_log'

class CommonLogParser

  # Common Log formats
  # ie. http://publib.boulder.ibm.com/tividd/td/ITWSA/ITWSA_info45/en_US/HTML/guide/c-logs.html#common
  #
  FORMATS = {
    # Regular Common Log format, allowing extra like Combined format
    regular:  /^(\S+) (\S+) (\S+) \[(.*)\] "(.*)" (\d{3}) (\d{1,})/
  }

  # Parse the input_log according to the chosen Common Log format
  #
  def self.parse(input_log, format = FORMATS[:regular])
    data = input_log.scan(format).flatten
    CommonLog.new(*data)
  end
end
