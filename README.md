# Rack::LocaleMemorable

Handle query params, cookie and HTTP_ACCEPT_LANGUAGE header to detect user-preffered locale, and remember it when necessary.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rack-locale_memorable

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rack-locale_memorable

## Usage

```ruby
# in initializers/middlewares.rb etc.
Rails.application.configure do |config|
  config.middleware.use Rack::LocaleMemorable
end
```

By default, this gem handles locale variables in 3 places in the order below, and when explicit locale is specified (= when locale is specified via query params) in the request, remember it in cookie too.

1. `params['locale']` as explicit locale
2. `cookies['locale']` as remembered locale
3. `headers['HTTP_ACCEPT_LANGUAGE']` as implicit locale

There are several customizable options listed below.

* params_key (`'locale'` by default)
* cookie_key (`'locale'` by default)
* secure_cookie (`true` by default)
* cookie_lifetime (`1.year` by default)

You can customize them like below

```ruby
Rails.application.configure do |config|
  config.middleware.use(
    Rack::LocaleMemorable,
    params_key: 'ui_locale',
    cookie_key: 'ui_locale',
    secure_cookie: Rails.env.production?,
    cookie_lifetime: 3.months
  )
end
```

NOTE: If you're using devise, set `Rack::LocaleMemorable` before `Warden::Manager`, otherwise you see warden error messages in wrong locale.

```ruby
Rails.application.configure do |config|
  config.middleware.insert_before Warden::Manager, Rack::LocaleMemorable
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nov/rack-locale_memorable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nov/rack-locale_memorable/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::LocaleMemorable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nov/rack-locale_memorable/blob/master/CODE_OF_CONDUCT.md).
