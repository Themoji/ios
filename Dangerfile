puts `bundle exec fastlane test`
Dir[File.join(ENV["CIRCLE_TEST_REPORTS"], "**/*.xml")].each do |path|
  puts "Parsing JUnit file at path '#{path}'"
  junit.parse(path)
  junit.report
end

puts "Running fastlane to generate and upload an ipa file..."

options = {
  xcodebuild: {
    scheme: "Themoji"
  }
}

require 'fastlane'
result = Fastlane::OneOff.run(action: "build_and_upload_to_appetize",
                          parameters: options)

device_grid.run(
  public_key: result,
  languages: ["en", "de"],
  devices: ["iphone5s", "iphone6splus", "ipadair"]
)
