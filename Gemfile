source "https://rubygems.org"

gem "cocoapods"
gem "bundler"
gem "fastlane"

gem "danger", git: "https://github.com/danger/danger"
gem "danger-device_grid"
gem "danger-junit", git: "https://github.com/orta/danger-junit"
gem "pry"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
