# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Themoji' do
  pod "EmojiKit"
  pod "PKHUD"
  pod "Fabric"
  pod "Crashlytics"
end

# Stolen from https://github.com/CocoaPods/CocoaPods/issues/4011#issuecomment-152688417
# Otherwise Xcode tries to sign the framework files
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end
