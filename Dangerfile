puts "Running fastlane to generate and upload an ipa file..."
puts `fastlane device_grid`

import "https://raw.githubusercontent.com/fastlane/fastlane/pr-preview/fastlane/lib/fastlane/actions/device_grid/device_grid.rb"
device_grid(
  languages: ["en", "de"],
  devices: ["iphone5s", "iphone6splus", "ipadair"]
)
