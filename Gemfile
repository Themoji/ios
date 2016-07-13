source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
gem "danger", git: "https://github.com/danger/danger", branch: "danger-org"
# gem "danger", path: "/Users/krausefx/Developer/danger"
gem "danger-device_grid"
gem "bundler"
gem "pry"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
