<img align="left" height="100" style="margin-right: 10px;" src="../img/icon.png">

# IDkollen Ruby Client

[![Gem version][gem-image]][gem-url]
[![MIT license][license-image]][license-url]

[gem-image]: https://img.shields.io/gem/v/idkollen-client?style=flat-square
[gem-url]: https://rubygems.org/gems/idkollen-client
[license-image]: https://img.shields.io/badge/license-MIT-blue?style=flat-square
[license-url]: https://opensource.org/license/mit

API client for the [IDkollen](https://developers.idkollen.se) REST API.

## Installation

```sh
gem install idkollen-client
```

Or add to your `Gemfile`:

```ruby
gem 'idkollen-client', '~> 0.1'
```

## Usage

```ruby
require 'idkollen/client'

client = Idkollen::ClientBuilder.new('client_id', 'client_secret')
                                  .environment(Idkollen::Environment::STAGING)
                                  .build

session = client.bank_id_se.auth(Idkollen::BankIdSe::AuthRequest.new)
puts "Session ID: #{session.id}" if session.is_a?(Idkollen::BankIdSe::Pending)

result = client.bank_id_se.wait_for_auth(session.id)

case result
in Idkollen::BankIdSe::Completed(ssn:, name:)
  puts "Authenticated: #{name} (#{ssn})"
in Idkollen::BankIdSe::Failed(error:)
  puts "Failed: #{error}"
end
```

## Development

### Prerequisites

- Ruby 3.2+
- Bundler

### Setup / Build / Test

```sh
bundle install
bundle exec rake test
```
