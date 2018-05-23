# EJSON::Rails

Automatically injects `ejson` decrypted secrets into your `Rails.application.secrets`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ejson-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ejson-rails

## Usage

Decrypted secrets from `project/config/secrets.json` (or `project/config/secrets.{current_rails_environment}.json` if that doesn't exist) will be accessible via `Rails.application.secrets`. For example:

```json
// project/config/secrets.json
{ "some_secret": "key" }
```

will be accessible via `Rails.application.secrets.some_secret` or `Rails.application.secrets[:some_secret]` on boot. JSON files are loaded once and contents are `deep_merge`'d into your app's existing rails secrets.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shopify/ejson-rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
