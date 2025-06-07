
$: << File.dirname(__FILE__)+"/../lib"
require 'io/console'
require 'keyboard_map'

kb = KeyboardMap.new

puts "'q' to quit"

at_exit do
    STDOUT.print "\e[?2004l" #Disable bracketed paste
    STDOUT.print "\e[?1000l" #Disable mouse reporting
end

STDOUT.print "\e[?2004h" # Enable bracketed paste
STDOUT.print "\e[?1000h" # Enable mouse reporting
STDOUT.print "\e[?1006h" # Enable extended reporting

IO.console.raw do
  loop do
    # We use a non-blocking read of multiple characters
    # in the hope of the read returning a complete sequence,
    # which allows us to assume a singular ESC is a single press of
    # the Esc key.
    #
    # If you don't need/care about Esc, you can replace the below
    # with ch = $stdin.getc and omit the `:finished` argument passed to
    # `call` below.
    #
    begin
      ch = $stdin.read_nonblock(32)
    rescue IO::WaitReadable
      IO.select([$stdin])
      retry
    end
    print "\rRaw:    #{ch.inspect}\n\r"
    r = kb.call(ch, :finished)
    r.each do |ev|
      case ev
      when KeyboardMap::Event
        puts "Event:  #{ev.inspect}"
        print "\r"
        puts "Symbol: #{ev.to_sym}"
      else
        print "Text:   #{ev}\n\r"
      end
    end
    print "\r"
    break if r.first == "q"
  end
end
