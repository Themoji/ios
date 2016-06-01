# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/emoji_fetcher/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-emoji_fetcher'
  spec.version       = Fastlane::EmojiFetcher::VERSION
  spec.author        = %q{Felix Krause}
  spec.email         = %q{emoji@krausefx.com}

  spec.summary       = %q{Fetch the emoji font file and copy it to a local directory}
  spec.homepage      = "https://github.com/Themoji/ios/tree/master/fastlane-plugin-emoji_fetcher"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'fastlane', '>= 1.91.0'
end
