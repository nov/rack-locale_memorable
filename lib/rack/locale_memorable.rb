# frozen_string_literal: true

require 'active_support'
require 'active_support/all'
require 'http/accept'
require 'rack'

module Rack
  class LocaleMemorable
    def initialize(app, secure_cookie: true, cookie_expiry: 1.year.from_now)
      @app = app
      @secure_cookie = secure_cookie
      @cookie_expiry = cookie_expiry
    end

    def call(env)
      request = Request.new(env)
      I18n.with_locale(request.detect_locale) do
        status, headers, body = @app.call(env)
        response = Response.new body, status, headers
        if request.explicit_locale.present?
          response.remember_locale(
            request.explicit_locale,
            secure_cookie: @secure_cookie,
            cookie_expiry: @cookie_expiry
          )
        end
        response.finish
      end
    end
  end
end

require 'rack/locale_memorable/version'
require 'rack/locale_memorable/request'
require 'rack/locale_memorable/response'