# Swarmclient-rb

- Bluzelle Hackathon 2018

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'swarmclient'
```

And then execute:

    $ bundle

Or build and install from src:

    $ git clone https://github.com/wlwanpan/swarmclient-rb.git
    $ gem build swarmclient.gemspec
    $ gem install swarmclient-0.1.0.gem

## Communication API (Swarmclient::Communication)

Require and Initialize
```
require 'swarmclient'

bluzelle = Swarmclient::Communication.new endpoint: "ws://127.0.0.1", port: 50001, uuid: "80174b53-2dda-49f1-9d6a-6a780d4"
```

Note: The uuid is the uniq id of a referenced db hosted in the swarm.
Generate a new one to generate a new store.
Refer to https://bluzelle.github.io/api/ for more info.

- Create New Entry (key-value)
```
bluzelle.create key: 'myKey', value: 'Your Value'
```

- Read Key
```
res = bluzelle.read 'myKey'
puts res
```
Result
```
=> {:data=>{:value=>"Your Value"}, :"request-id"=>0.5304515448110283}
```

- Update Key value
```
bluzelle.update 'myKey', 'New Value'
```

- Remove Key
```
bluzelle.remove 'myKey'
```

- Check if key exist
```
res = bluzelle.has 'myKey'
puts res
```
Result
```
=> {:data=>{:"key-exists"=>true}, :"request-id"=>0.7938161241077408}
```

- Read all keys stored
```
bluzelle.keys
```
Result
```
 => {:data=>{:keys=>["myKey"]}, :"request-id"=>0.7472509525271954}
```

## Pubsub (Swarmclient::Pubsub)

For data streaming -> WIP

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wlwanpan/swarmclient-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
