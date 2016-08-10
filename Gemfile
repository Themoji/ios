source "https://rubygems.org"

gem "cocoapods"
gem "bundler"

gem "scan", git: "https://github.com/fastlane/fastlane", branch: "scan-derived-data"
gem "fastlane", git: "https://github.com/fastlane/fastlane", branch: "scan-derived-data"

gem "danger", git: "https://github.com/danger/danger"
gem "danger-device_grid"
gem "danger-junit", git: "https://github.com/KrauseFx/danger-junit", branch: "fix-parsing-crashes"
gem "pry"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
