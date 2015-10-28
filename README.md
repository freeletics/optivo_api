# OptivoApi

OptivoApi is a wrapper for the  [Optivo SOAP API](https://companion.broadmail.de/display/DEMANUAL/SOAP-API)
This is only a small set of the whole functionality of the api.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'optivo_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install optivo_api

## Config for Rails

    OptivoApi.configure do | config|
      config.mandator_id = "666"
      config.user = "user@test.com"
      config.password = "secret"
      config.logger = Rails.logger
      config.cache =  Rails.cache
    end

## Usage Examples
After configuring the `OptivoApi`, you can do the following things.

**fetch all recipent-lists**

```ruby
recipient_list = OptivoApi::WebServices::RecipientList.new
recipient_list.all
```
**add a user to a recipient-list**

```ruby
receipient = OptivoApi::WebServices::Recipient.new
recipient_service.add(
      list_id: 1234,
      email: "my–email@test.com",
      attribute_names:  [:first_name, :last_name],
      attribute_values: ["Max", "Mad"]
```
**remove a user from a list**

```ruby
receipient = OptivoApi::WebServices::Recipient.new
receipient.remove(list_id: 1234, email: "my–email@test.com")
```

**send a mail to a user**

```ruby
mailing = OptivoApi::WebServices::Mailing.new
mailing.send_mail(list_id: 1234, mailing_id: 1234, email: "my–email@test.com")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/freeletics/optivo_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
