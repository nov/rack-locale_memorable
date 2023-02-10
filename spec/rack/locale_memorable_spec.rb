# frozen_string_literal: true

class Rack::LocaleMemorable::TestApplication
  def call(_env)
    [200, {}, I18n.locale]
  end
end

RSpec.describe Rack::LocaleMemorable do
  include Rack::Test::Methods

  let(:app) { described_class.new Rack::LocaleMemorable::TestApplication.new }
  let(:env) { Rack::MockRequest.env_for('/', headers.merge(params: params)) }
  let(:params) { {} }
  let(:headers) { {} }
  let(:request) { app.call(env) }
  let(:params_key) { 'locale' }
  let(:cookie_key) { 'locale' }

  before do
    I18n.available_locales = [:en, :ja]
    I18n.default_locale = :ja
  end

  shared_examples :handled_with_default_locale do
    it 'should use default locale' do
      _status, headers, body = request
      expect(headers['Content-Language']).to eq I18n.default_locale.to_s
      expect(body).to eq I18n.default_locale
      expect(env['rack.locale']).to eq I18n.default_locale.to_s
    end
  end

  shared_examples :handled_with_expected_locale do
    it 'should use expected locale' do
      _status, headers, body = request
      expect(headers['Content-Language']).to eq expected_locale.to_s
      expect(body).to eq expected_locale
      expect(env['rack.locale']).to eq expected_locale.to_s
    end
  end

  shared_examples :remember_expected_locale do
    it 'should remember expected locale' do
      _status, headers, _body = request
      expect(headers['Set-Cookie']).not_to be_nil
      expect(headers['Set-Cookie']).not_to be_empty
      expect(headers['Set-Cookie']).to include "#{cookie_key}=#{expected_locale}"
    end
  end

  shared_examples :remember_no_locale do
    it 'should not remember any locale' do
      _status, headers, _body = request
      expect(headers['Set-Cookie']).to be_nil
    end
  end

  context 'with no locales' do
    it_behaves_like :handled_with_default_locale
  end

  describe 'channel priority' do
    let(:expected_locale) { :en }
    let(:different_locale) { :ja }

    context 'when locale is specified' do
      context 'via query' do
        let(:params) do
          {
            params_key => expected_locale
          }
        end

        context 'when different locale is included' do
          context 'in cookie' do
            let(:headers) do
              {
                'HTTP_COOKIE' => "#{cookie_key}=#{different_locale}"
              }
            end
            it_behaves_like :handled_with_expected_locale
            it_behaves_like :remember_expected_locale
          end

          context 'in header' do
            let(:headers) do
              {
                'HTTP_ACCEPT_LANGUAGE' => different_locale.to_s
              }
            end
            it_behaves_like :handled_with_expected_locale
            it_behaves_like :remember_expected_locale
          end

          context 'in cookie & header' do
            let(:headers) do
              {
                'HTTP_COOKIE' => "#{cookie_key}=#{different_locale}",
                'HTTP_ACCEPT_LANGUAGE' => different_locale.to_s
              }
            end
            it_behaves_like :handled_with_expected_locale
            it_behaves_like :remember_expected_locale
          end
        end
      end

      context 'via cookie' do
        context 'when different locale is included' do
          context 'in header' do
            let(:headers) do
              {
                'HTTP_COOKIE' => "#{cookie_key}=#{expected_locale}",
                'HTTP_ACCEPT_LANGUAGE' => different_locale.to_s
              }
            end
            it_behaves_like :handled_with_expected_locale
            it_behaves_like :remember_no_locale
          end
        end
      end
    end
  end

  I18n.available_locales.each do |specified_locale|
    context "with locale=#{specified_locale}" do
      let(:expected_locale) { specified_locale }

      context 'via query' do
        let(:params) do
          {
            params_key => specified_locale
          }
        end
        it_behaves_like :handled_with_expected_locale
        it_behaves_like :remember_expected_locale
      end

      context 'via cookie' do
        let(:headers) do
          {
            'HTTP_COOKIE' => "#{cookie_key}=#{specified_locale}"
          }
        end
        it_behaves_like :handled_with_expected_locale
        it_behaves_like :remember_no_locale
      end

      context 'via header' do
        let(:headers) do
          {
            'HTTP_ACCEPT_LANGUAGE' => specified_locale.to_s
          }
        end
        it_behaves_like :handled_with_expected_locale
        it_behaves_like :remember_no_locale
      end
    end
  end

  {
    'ja-JP' => :ja,
    'en-US' => :en,
    'en-UK' => :en,
    'ja-JP,ja' => :ja,
    'en-US,en' => :en,
    'en-UK,en' => :en,
    'en-UK,en-US,en' => :en,
    'ja-JP,en-US' => :ja,
    'en-US,ja-JP' => :en,
    'en-UK, fr;q=0.9, zh;q=0.8, de;q=0.7, *;q=0.5' => :en
  }.each do |specified_locale, expected_locale|
    context "with locale=#{specified_locale}" do
      let(:expected_locale) { expected_locale }

      context 'via query' do
        let(:params) do
          {
            params_key => specified_locale
          }
        end
        it_behaves_like :handled_with_expected_locale
        it_behaves_like :remember_expected_locale
      end

      context 'via cookie' do
        let(:headers) do
          {
            'HTTP_COOKIE' => "#{cookie_key}=#{specified_locale}"
          }
        end
        it_behaves_like :handled_with_expected_locale
        it_behaves_like :remember_no_locale
      end

      context 'via header' do
        let(:headers) do
          {
            'HTTP_ACCEPT_LANGUAGE' => specified_locale.to_s
          }
        end
        it_behaves_like :handled_with_expected_locale
        it_behaves_like :remember_no_locale
      end
    end
  end

  ['', ',en', 'fr', 'fr;q=0.9, zh;q=0.8, de;q=0.7, *;q=0.5'].each do |specified_locale|
    context "with locale=#{specified_locale}" do
      context 'via query' do
        let(:params) do
          {
            params_key => specified_locale
          }
        end
        it_behaves_like :handled_with_default_locale
      end

      context 'via cookie' do
        let(:headers) do
          {
            'HTTP_COOKIE' => "#{cookie_key}=#{specified_locale}"
          }
        end
        it_behaves_like :handled_with_default_locale
      end

      context 'via header' do
        let(:headers) do
          {
            'HTTP_ACCEPT_LANGUAGE' => specified_locale.to_s
          }
        end
        it_behaves_like :handled_with_default_locale
      end
    end
  end

  describe 'customizable options' do
    context 'when params_key is specified' do
      let(:app) { described_class.new Rack::LocaleMemorable::TestApplication.new, params_key: params_key }
      let(:params_key) { 'ui_locale' }
      let(:specified_locale) { :en }
      let(:expected_locale) { specified_locale }
      let(:params) do
        {
          params_key => specified_locale
        }
      end
      it_behaves_like :handled_with_expected_locale
      it_behaves_like :remember_expected_locale

      context 'when cookie_key is specified' do
        let(:app) { described_class.new Rack::LocaleMemorable::TestApplication.new, params_key: params_key, cookie_key: cookie_key }
        let(:cookie_key) { 'ui_locale' }
        it_behaves_like :handled_with_expected_locale
        it_behaves_like :remember_expected_locale
      end
    end

    context 'when cookie_key is specified' do
      let(:app) { described_class.new Rack::LocaleMemorable::TestApplication.new, cookie_key: cookie_key }
      let(:cookie_key) { 'ui_locale' }
      let(:specified_locale) { :en }
      let(:expected_locale) { specified_locale }
      let(:headers) do
        {
          'HTTP_COOKIE' => "#{cookie_key}=#{specified_locale}"
        }
      end
      it_behaves_like :handled_with_expected_locale
      it_behaves_like :remember_no_locale
    end

    describe 'cookie_options' do
      let(:app) { described_class.new Rack::LocaleMemorable::TestApplication.new, cookie_options: cookie_options }
      let(:specified_locale) { :en }
      let(:expected_locale) { specified_locale }
      let(:params) do
        {
          params_key => specified_locale
        }
      end

      context 'when lifetime is specified' do
        let(:cookie_options) do
          {
            lifetime: 7776000
          }
        end

        it 'should use it' do
          Timecop.freeze do
            expect_any_instance_of(Rack::LocaleMemorable::Response).to receive(:set_cookie).with(cookie_key, {
              value: expected_locale.to_s,
              expires: Time.at(Time.now.to_i + cookie_options[:lifetime]),
              path: '/',
              http_only: true,
              secure: true
            })
            request
          end
        end
      end

      context 'when domain is specified' do
        let(:cookie_options) do
          {
            domain: '.example.com'
          }
        end

        it 'should use it' do
          Timecop.freeze do
            expect_any_instance_of(Rack::LocaleMemorable::Response).to receive(:set_cookie).with(cookie_key, {
              value: expected_locale.to_s,
              expires: Time.at(Time.now.to_i + 31536000),
              domain: cookie_options[:domain],
              path: '/',
              http_only: true,
              secure: true
            })
            request
          end
        end
      end

      context 'when path is specified' do
        let(:cookie_options) do
          {
            path: '/foo'
          }
        end

        it 'should use it' do
          Timecop.freeze do
            expect_any_instance_of(Rack::LocaleMemorable::Response).to receive(:set_cookie).with(cookie_key, {
              value: expected_locale.to_s,
              expires: Time.at(Time.now.to_i + 31536000),
              path: cookie_options[:path],
              http_only: true,
              secure: true
            })
            request
          end
        end
      end

      context 'when http_only is specified' do
        let(:cookie_options) do
          {
            http_only: false
          }
        end

        it 'should use it' do
          Timecop.freeze do
            expect_any_instance_of(Rack::LocaleMemorable::Response).to receive(:set_cookie).with(cookie_key, {
              value: expected_locale.to_s,
              expires: Time.at(Time.now.to_i + 31536000),
              path: '/',
              http_only: false,
              secure: true
            })
            request
          end
        end
      end

      context 'when secure is specified' do
        let(:cookie_options) do
          {
            secure: false
          }
        end

        it 'should use it' do
          Timecop.freeze do
            expect_any_instance_of(Rack::LocaleMemorable::Response).to receive(:set_cookie).with(cookie_key, {
              value: expected_locale.to_s,
              expires: Time.at(Time.now.to_i + 31536000),
              path: '/',
              http_only: true,
              secure: false
            })
            request
          end
        end
      end

      context 'when same_site is specified' do
        let(:cookie_options) do
          {
            same_site: :none
          }
        end

        it 'should use it' do
          Timecop.freeze do
            expect_any_instance_of(Rack::LocaleMemorable::Response).to receive(:set_cookie).with(cookie_key, {
              value: expected_locale.to_s,
              expires: Time.at(Time.now.to_i + 31536000),
              path: '/',
              http_only: true,
              secure: true,
              same_site: :none
            })
            request
          end
        end
      end
    end
  end
end
