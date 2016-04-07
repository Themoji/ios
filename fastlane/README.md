fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions

----

## iOS
### ios device_grid
```
fastlane ios device_grid
```
Generate and upload an .app to appetize.io

This is being called from danger
### ios bootstrap
```
fastlane ios bootstrap
```
Set up a new Mac

To run this in readonly mode without user credentials use

fastlane bootstrap readonly:true
### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios appstore
```
fastlane ios appstore
```


----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools).
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).