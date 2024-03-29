# Rack::LocaleMemorable

Handle query params, cookie and HTTP_ACCEPT_LANGUAGE header to detect user-preffered locale, and remember it when necessary.

Since some libraries (e.g., Devise & Warden) or applications may handle i18n strings in rack-middleware layer, setting `I18n.locale` in Rails layer is not enough in such cases.

This gem sets `I18n.locale` in rack-middleware layer, so that you can let other rack-middlewares use proper `I18n.locale`.

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

* `params_key` (`'locale'` by default)
* `cookie_key` (`'locale'` by default)
* `cookie_options[:lifetime]` (`1.year` by default)
* `cookie_options[:domain]` (`nil` by default)
* `cookie_options[:path]` (`/` by default)
* `cookie_options[:http_only]` (`true` by default)
* `cookie_options[:secure]` (`true` by default)
* `cookie_options[:same_site]` (`nil` by default)

You can customize them like below

```ruby
Rails.application.configure do |config|
  config.middleware.use(
    Rack::LocaleMemorable,
    params_key: 'ui_locale',
    cookie_key: 'ui_locale',
    cookie_options: {
      lifetime:  3.months,
      domain:    'example.com',
      path:      '/localized',
      http_only: false,
      secure:    Rails.env.production?,
      same_site  :none
    }
  )
end
```

NOTE: If you're using devise, set `Rack::LocaleMemorable` before `Warden::Manager`, otherwise you might see warden error messages in wrong locale.

```ruby
Rails.application.configure do |config|
  config.middleware.insert_before Warden::Manager, Rack::LocaleMemorable
end
```

ref.) related issue in devise & warden
* https://github.com/heartcombo/devise/issues/5247
* https://github.com/wardencommunity/warden/issues/180


## Detailed locale handling

See rspec results.

```console
% bundle exec rspec --format=documentation

Rack::LocaleMemorable
  with no locales
    behaves like handled_with_default_locale
      should use default locale
  channel priority
    when locale is specified
      via query
        when different locale is included
          in cookie
            behaves like handled_with_expected_locale
              should use expected locale
            behaves like remember_expected_locale
              should remember expected locale
          in header
            behaves like handled_with_expected_locale
              should use expected locale
            behaves like remember_expected_locale
              should remember expected locale
          in cookie & header
            behaves like handled_with_expected_locale
              should use expected locale
            behaves like remember_expected_locale
              should remember expected locale
      via cookie
        when different locale is included
          in header
            behaves like handled_with_expected_locale
              should use expected locale
            behaves like remember_no_locale
              should not remember any locale
              :
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
