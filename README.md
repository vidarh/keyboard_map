# KeyboardMap

Process key-presses and map escape-sequences to symbols.

E.g instead of getting ASCII 0x03 you'll get `:ctrl_c`

Dealing with raw keyboard input is painful because something like
cursor-up can return several different sequences depending on terminal,
*and* because there is no terribly simple algorithm determining what
represents the end of a single sequence. In fact some software relies on
key-presses being slow enough to set a timeout and read character by
character.

KeyboardMap allows you to handle the reads in whichever way you prefer.
It simply provides a simple state machine that will return an array of
the keyboard events found so far.

### Current state

This is currently usable and I rely on it daily in my personal editor,
which uses this gem for keyboard processing.

However there are many missing sequences (PR's welcome), and it's likely
that it will misreport sequences for certain terminals (PR's also
welcome), so use with some caution.

Eventually it's likely it will need to deal with termcaps etc., but at
the moment I'm "cheating" and relying on the fact that most modern
terminals support a mostly shared subset of VT100.

You can use the example in examples/example.rb to get an idea of what
your terminal returns for a given keyboard sequence. If you run into
problems, please include the output from that when filing an issue,
combined with your *expected* result.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'keyboard_map'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keyboard_map

## Usage

See a full example in `examples/example.rb`, but the basics:

```ruby
require 'bundler'
require 'io/console'
require 'keyboard_map'

kb = KeyboardMap.new

IO.console.raw do # You want to get individual keypresses.
  loop do
    ch = $stdin.getc

    # events can include zero or more events.
    # Zero events will happen if the character
    # is part of a compound sequence

    events = kb.call(ch)
    events.each do |e|
      # Process events here.
      p e
    end
  end
end
```

### But I want to catch "Esc"

If you're sure you've read a complete sequence, you can do this
by passing :finished as a second argument to call, or by calling the
`#finish` method. You can see this done in `examples/example.rb`

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will create
a git tag for the version, push git commits and tags, and push the `.gem`
file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/vidarh/keyboard_map.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
