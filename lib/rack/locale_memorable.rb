# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'http/accept'
require 'rack'

module Rack
  class LocaleMemorable
    def initialize(app, params_key: 'locale', cookie_key: 'locale', cookie_options: {})
      @app = app
      @params_key = params_key
      @cookie_key = cookie_key
      @cookie_options = cookie_options
    end

    def call(env)
      request = Request.new env
      I18n.with_locale(request.detect_locale params_key: @params_key, cookie_key: @cookie_key) do
        status, headers, body = @app.call(env)
        response = Response.new body, status, headers
        if request.explicit_locale.present?
          response.remember_locale(
            request.explicit_locale,
            **@cookie_options.merge(key: @cookie_key)
          )
        end
        response.finish
      end
    end
  end
end

require_relative 'locale_memorable/version'
require_relative 'locale_memorable/request'
require_relative 'locale_memorable/response'