source "https://rubygems.org"

gem "fastlane", path: "/Users/fkrause/Developer/fastlane/fastlane"
gem "scan", path: "/Users/fkrause/Developer/fastlane/scan"
gem "cocoapods"
gem "bundler"

gem "danger", git: "https://github.com/danger/danger"
gem "danger-device_grid"
# gem "danger-junit"
gem "pry"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
