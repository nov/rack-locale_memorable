# frozen_string_literal: true

module Rack
  class LocaleMemorable
    class Response < Rack::Response
      def remember_locale(explicit_locale, key:, lifetime: 1.year, domain: nil, path: '/', http_only: true, secure: true)
        set_cookie key, {
          value:     explicit_locale,
          expires:   lifetime.from_now,
          domain:    domain,
          path:      path,
          http_only: http_only,
          secure:    secure
        }.compact
      end

      def finish
        headers['Content-Language'] ||= I18n.locale.to_s
        super
      end
    end
  end
end