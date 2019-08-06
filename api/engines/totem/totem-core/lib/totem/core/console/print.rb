module Totem; module Core; module Console; class Print

  DEFAULT_COLOR = :light_cyan

  PRINT_COLORS = {
    clear:            "\e[0m",   # Embed in a String to clear all previous ANSI sequences.
    bold:             "\e[1m",   # The start of an ANSI bold sequence.
    black:            "\e[30m",
    red:              "\e[31m",
    green:            "\e[32m",
    yellow:           "\e[33m",
    blue:             "\e[34m",
    magenta:          "\e[35m",
    cyan:             "\e[36m",
    gray:             "\e[90m",
    white:            "\e[97m",
    light_gray:       "\e[37m",
    light_red:        "\e[91m",
    light_green:      "\e[92m",
    light_yellow:     "\e[93m",
    light_blue:       "\e[94m",
    light_magenta:    "\e[95m",
    light_cyan:       "\e[96m",
    on_black:         "\e[40m",
    on_red:           "\e[41m",
    on_green:         "\e[42m",
    on_yellow:        "\e[43m",
    on_blue:          "\e[44m",
    on_magenta:       "\e[45m",
    on_cyan:          "\e[46m",
    on_light_gray:    "\e[47m",
    on_gray:          "\e[100m",
    on_light_red:     "\e[101m",
    on_light_green:   "\e[102m",
    on_light_yellow:  "\e[103m",
    on_light_blue:    "\e[104m",
    on_light_magenta: "\e[105m",
    on_light_cyan:    "\e[106m",
    on_white:         "\e[107m",
  }

  def line(str, c=nil, b=nil); $stdout.print color(str, c, b) + "\n"; end

  def inline(str, c=nil, b=nil); $stdout.print color(str, c, b); end

  def new_line; $stdout.print "\n"; end

  def color(str, c=DEFAULT_COLOR, b=nil)
    return str if @no_color
    return str unless c
    if c == :bold
      c = DEFAULT_COLOR
      b = :bold
    end
    str = bold + str  if b == :bold
    prt_color = PRINT_COLORS[c]
    error "Print color '#{c.inspect}' is not supported." if prt_color.blank?
    prt_color + str + clear
  end

  def clear; PRINT_COLORS[:clear]; end
  def bold;  PRINT_COLORS[:bold]; end

  def error(message)
    line message, :red
    exit
  end

  def ask(message='', c=nil, b=nil)
    line message, c, b
    (STDIN.gets.chomp || '').strip
  end

  def ask_inline(message='', c=nil, b=nil)
    inline message, c, b
    (STDIN.gets.chomp || '').strip
  end

  def clear_console; system('clear') or system('cls'); end

end; end; end; end
