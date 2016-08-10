source "https://rubygems.org"

gem "cocoapods"
gem "bundler"

TOOLS = [
  :fastlane,
  :pilot,
  :spaceship,
  :produce,
  :deliver,
  :frameit,
  :pem,
  :snapshot,
  :screengrab,
  :supply,
  :cert,
  :sigh,
  :match,
  :scan,
  :gym
].each do |gem_name|
  gem gem_name.to_s, git: "https://github.com/fastlane/fastlane", branch: "scan-derived-data"
end

gem "danger", git: "https://github.com/danger/danger"
gem "danger-device_grid"
gem "danger-junit", git: "https://github.com/KrauseFx/danger-junit", branch: "fix-parsing-crashes"
gem "pry"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
