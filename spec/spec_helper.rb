# frozen_string_literal: true

require 'simplecov'

if ENV['GITHUB_ACTIONS']
  require 'simplecov-lcov'
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
end

SimpleCov.start do
  add_filter 'spec'
end

require 'rspec'
require 'timecop'
require 'rack/test'
require 'rack/locale_memorable'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end