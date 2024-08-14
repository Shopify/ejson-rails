# EJSON::Rails

[![Build Status](https://github.com/Shopify/ejson-rails/workflows/CI/badge.svg?branch=main)](https://github.com/Shopify/ejson-rails/actions?query=branch%3Amain)

Automatically injects [`ejson`](https://github.com/Shopify/ejson) decrypted secrets into your `Rails.application.credentials`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ejson-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ejson-rails

## Configuration

By default, the gem will look for decrypted secrets in `project/config/secrets.json` or `project/config/secrets.{current_rails_environment}.json` if that doesn't exist.

If your application or environment has a unique way of retrieving decrypted secrets, you can do so by setting `EJSON::Rails::Railtie.ejson_secret_source` to a callable object in `config/application.rb`. For example:

```ruby
# config/application.rb

# This must be placed BEFORE your application constant which inherits from Rails::Application
EJSON::Rails::Railtie.ejson_secret_source = FooBar::SecretCredentialReader

# Custom credential reader that lives somewhere else
module FooBar
  class SecretCredentialReader
    class << self
      def call
        '{"secret": "secret_from_ejson_secret_source"}'
      end
    end
  end
end
```

For simple cases, you can use a `proc`:

```ruby
EJSON::Rails::Railtie.ejson_secret_source = proc { '{"secret": "secret_from_ejson_secret_source"}' }
```

## Usage

Decrypted secrets will be accessible via `Rails.application.credentials`. For example:

`# project/config/secrets.json`

```json
{ "some_secret": "key" }
```

will be accessible via `Rails.application.credentials.some_secret` or `Rails.application.credentials[:some_secret]` upon booting. JSON files are loaded once and contents are `deep_merge`'d into your app's existing Rails credentials.

To avoid subtle compatibility issues, if a credential already exists, an error will occur.

If you set the `EJSON_RAILS_DELETE_SECRETS` environment variable to `true` the gem will automatically delete the secrets from the filesystem after loading them into Rails. It will delete both paths (`project/config/secrets.json` and `project/config/secrets.{current_rails_environment}.json`) if the files exist and are writable.

NOTE: This gem does not decrypt ejson for you. You will need to configure this as part of your deployment pipeline.

## Migrating to credentials

Rails 7.1 has deprecated application secrets in favor of credentials. `ejson-rails` no longer writes to Rails secrets to avoid crashing given Rails 7.2 removal of the feature. See the README for the last version that supports secrets to read more about migrating: [`ejson-rails` v0.2.2 – Migrating to credentials](https://github.com/Shopify/ejson-rails/tree/v0.2.2#migrating-to-credentials).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shopify/ejson-rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
