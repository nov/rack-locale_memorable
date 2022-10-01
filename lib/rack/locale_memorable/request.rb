# frozen_string_literal: true

module Rack
  class LocaleMemorable
    class Request < Rack::Request
      attr_reader :explicit_locale

      def detect_locale(params_key:, cookie_key:)
        (
          from_params(params_key) ||
          from_cookies(cookie_key) ||
          from_headers
        )
      end

      private

      def from_params(key)
        @explicit_locale = primary_locale_from params[key]
      end

      def from_cookies(key)
        primary_locale_from cookies[key]
      end

      def from_headers
        primary_locale_from get_header('HTTP_ACCEPT_LANGUAGE')
      end

      def primary_locale_from(locales)
        available_locales_from(locales)&.first if locales
      end

      def available_locales_from(locales)
        (
          HTTP::Accept::Languages::Locales.new(I18n.available_locales.map(&:to_s)) &
          HTTP::Accept::Languages.parse(
            HTTP::Accept::Languages::Locales.new(
              HTTP::Accept::Languages.parse(locales).collect(&:locale)
            ).patterns.keys.join(',')
          )
        )
      rescue
        nil
      end
    end
  end
end