# require "term/ansicolor"

begin
  require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
end

class String
  
  # colorization
  def colorize(color_code, use_color=true)
    if use_color
      return "\e[#{color_code}m#{self}\e[0m"
    else
      return self
    end
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end