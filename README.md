# Rustore connect plugin

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-rustore_connect`, declare it to your Gemfile by command:

```bash
gem "fastlane-plugin-rustore_connect", git: "https://github.com/BMariya/fastlane-plugin-rustore_connect", branch: 'main'
```

## About rustore connect

Allows send for moderation aab with google services and apk with hms services to Rustore

```ruby
rustore_connect(
  key_id_path: ENV["RUSTORE_KEY_ID_PATH"], # path to Rustore key id
  private_key_path: ENV["RUSTORE_PRIVATE_KEY_PATH"], # path to Rustore private key
  package_name: ENV["RUSTORE_PACKAGE_NAME"], # package name of the app
  aab_google_path: ENV["RUSTORE_AAB_GOOGLE_PATH"], # path to aab with google services
  apk_hms_path: ENV["RUSTORE_APK_HMS_PATH"], # path to apk with hms services
  release_notes_path: ENV["RUSTORE_RELEASE_NOTES_PATH"], # path to release notes
  release_percent: ENV["RUSTORE_RELEASE_PERCENT"] # percent for publication
)
```
