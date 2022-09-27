# frozen_string_literal: true

module Rack
  class LocaleMemorable
    class Response < Rack::Response
      def remember_locale(explicit_locale, secure_cookie:, cookie_expiry:)
        set_cookie 'locale', {
          value: explicit_locale,
          expires: cookie_expiry,
          http_only: true,
          secure: secure_cookie
        }
      end
    end
  end
end