source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
gem "danger", git: "https://github.com/danger/danger"
gem "danger-device_grid", git: "https://github.com/neonichu/fastlane", branch: "migrate-device_grid-danger-plugin"
gem "bundler"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
