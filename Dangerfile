puts "Running fastlane to generate and upload an ipa file..."

options = {
  xcodebuild: {
    scheme: "Themoji"
  }
}

require 'fastlane'
result = Fastlane::OneOff.run(action: "build_and_upload_to_appetize",
                          parameters: options)
require 'fastlane/actions/device_grid/device_grid'

device_grid(
  public_key: result,
  languages: ["en", "de"],
  devices: ["iphone5s", "iphone6splus", "ipadair"]
)
