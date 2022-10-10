# frozen_string_literal: true

require_relative 'lib/rack/locale_memorable/version'

Gem::Specification.new do |spec|
  spec.name = 'rack-locale_memorable'
  spec.version = Rack::LocaleMemorable::VERSION
  spec.authors = ['nov']
  spec.email = ['nov@matake.jp']

  spec.summary = 'Remember locale in rack layer'
  spec.description = 'Remember locale in rack layer'
  spec.homepage = 'https://github.com/nov/rack-locale_memorable'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = File.join(spec.homepage, 'blob/main/CHANGELOG.md')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rack'
  spec.add_dependency 'i18n'
  spec.add_dependency 'http-accept'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'timecop'
end
