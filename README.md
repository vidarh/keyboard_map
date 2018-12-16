# KeyboardMap

Process key-presses and map escape-sequences to symbols.

Dealing with raw keyboard input is painful because something like cursor-up
can return several different sequences depending on terminal, *and* because
there is no terribly simple algorithm determining what represents the
end of a single sequence. In fact some software relies on key-presses being
slow enough to set a timeout and read character by character.

KeyboardMap allows you to handle the reads in whichever way you prefer.
It simply provides a simple state machine that will return an array of
the keyboard events found so far.

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

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vidarh/keyboard_map.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
