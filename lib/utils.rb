class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def blue
    colorize(34)
  end

  def green
    colorize(32)
  end
end

class Integer
  UNITS = %W(B KB MB GB TB).freeze

  # Convert current value to a more readable output
  # Ex: 1024 bytes to 1 MB
  #
  def as_readable_bytes
    converted_value = self

    if self.to_i < 1024
      exponent = 0
    else
      max_exp  = UNITS.size - 1

      # Convert to base
      exponent = (Math.log(self) / Math.log(1024)).to_i
      # We need this to avoid overflow for the highest unit
      exponent = max_exp if exponent > max_exp

      converted_value = self / (1024 ** exponent)
    end

    "#{converted_value} #{UNITS[ exponent ]}"
  end
end
