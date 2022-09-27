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

  before do
    I18n.available_locales = [:en, :ja]
    I18n.default_locale = :ja
  end

  shared_examples :handled_with_default_locale do
    it 'should handled with default locale' do
      _status, headers, body = request
      expect(headers).to be_blank
      expect(body).to eq I18n.default_locale
    end
  end

  shared_examples :handled_with_specified_locale do
    it 'should handled with specified locale' do
      _status, _headers, body = request
      expect(body).to eq expected_locale
    end
  end

  shared_examples :remember_specified_locale do
    it 'should remember specified locale' do
      _status, headers, _body = request
      expect(headers['Set-Cookie']).not_to be_blank
      expect(headers['Set-Cookie']).to include "locale=#{expected_locale}"
    end
  end

  shared_examples :remember_no_locale do
    it 'should not remember specified locale' do
      _status, headers, _body = request
      expect(headers['Set-Cookie']).to be_blank
    end
  end

  describe 'GET /' do
    context 'with no locales' do
      it_behaves_like :handled_with_default_locale
    end

    I18n.available_locales.each do |specified_locale|
      context "with locale=#{specified_locale}" do
        let(:expected_locale) { specified_locale }

        context 'in query' do
          let(:params) do
            {
              'locale' => specified_locale
            }
          end
          it_behaves_like :handled_with_specified_locale
          it_behaves_like :remember_specified_locale
        end

        context 'in cookie' do
          let(:headers) do
            {
              'HTTP_COOKIE' => "locale=#{specified_locale}"
            }
          end
          it_behaves_like :handled_with_specified_locale
          it_behaves_like :remember_no_locale
        end

        context 'in header' do
          let(:headers) do
            {
              'HTTP_ACCEPT_LANGUAGE' => specified_locale.to_s
            }
          end
          it_behaves_like :handled_with_specified_locale
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

        context 'in query' do
          let(:params) do
            {
              'locale' => specified_locale
            }
          end
          it_behaves_like :handled_with_specified_locale
          it_behaves_like :remember_specified_locale
        end

        context 'in cookie' do
          let(:headers) do
            {
              'HTTP_COOKIE' => "locale=#{specified_locale}"
            }
          end
          it_behaves_like :handled_with_specified_locale
          it_behaves_like :remember_no_locale
        end

        context 'in header' do
          let(:headers) do
            {
              'HTTP_ACCEPT_LANGUAGE' => specified_locale.to_s
            }
          end
          it_behaves_like :handled_with_specified_locale
          it_behaves_like :remember_no_locale
        end
      end
    end

    [',en', 'fr', 'fr;q=0.9, zh;q=0.8, de;q=0.7, *;q=0.5'].each do |specified_locale|
      context "with locale=#{specified_locale}" do
        context 'in query' do
          let(:params) do
            {
              'locale' => specified_locale
            }
          end
          it_behaves_like :handled_with_default_locale
        end

        context 'in cookie' do
          let(:headers) do
            {
              'HTTP_COOKIE' => "locale=#{specified_locale}"
            }
          end
          it_behaves_like :handled_with_default_locale
        end

        context 'in header' do
          let(:headers) do
            {
              'HTTP_ACCEPT_LANGUAGE' => specified_locale.to_s
            }
          end
          it_behaves_like :handled_with_default_locale
        end
      end
    end
  end
end
