# Swarmclient-rb

[![Build Status](https://api.travis-ci.org/wlwanpan/swarmclient-rb.png?branch=master)](https://travis-ci.org/wlwanpan/swarmclient-rb)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Twitter](https://img.shields.io/badge/twitter-@bluzelle-blue.svg?style=flat-square)](https://twitter.com/BluzelleHQ)
[![Gitter chat](https://img.shields.io/gitter/room/nwjs/nw.js.svg?style=flat-square)](https://gitter.im/bluzelle)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'swarmclient'
```

And then execute:

    $ bundle

Or build and install from src:

    $ git clone https://github.com/wlwanpan/swarmclient-rb.git
    $ cd swarmclient-rb && bundle install
    $ gem build swarmclient.gemspec
    $ gem install swarmclient-{GEM_VERSION}.gem

## Communication API (Swarmclient::Communication)

Require and Initialize
```ruby
require 'swarmclient'

bluzelle = Swarmclient::Communication.new endpoint: '127.0.0.1', port: 51010, uuid: '80174b53-2dda-49f1-9d6a-6a780d4'
```

Note: The uuid is the unique id of a referenced db hosted in the swarm.
Generate a new one to generate a new database. The gem will default to:
"8c073d96-7291-11e8-adc0-fa7ae01bbebc" if none is provided.

Create New Entry (key-value)
```ruby
bluzelle.create 'myKey', 'Your Value'
```
- Result
```ruby
=> true
```

Read Key
```ruby
bluzelle.read 'myKey'
```
- Result
```ruby
=> "Your Value"
```

Update Key value
```ruby
bluzelle.update 'myKey', 'New Value'
```
- Result
```ruby
=> true
```

Remove Key
```ruby
bluzelle.remove 'myKey'
```
- Result
```ruby
=> true
```

Check if key exist
```ruby
bluzelle.has 'myKey'
```
- Result
```ruby
=> true
```

Read all keys stored
```ruby
bluzelle.keys
```
- Result
```ruby
 => ["myKey"]
```

Get size of database
```ruby
bluzelle.size
```
- Result
```ruby
=> 1
```

## Reference

Visit the official bluzelle [documentation](https://bluzelle.github.io/api/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wlwanpan/swarmclient-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is under the terms of the [Apache License](http://www.apache.org/licenses/).
