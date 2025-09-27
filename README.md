## Getting Started

### Requirements

- Flutter SDK: 3.35.1
- CocoaPods: 1.16.2
- JVM: 17+

### How to run app

- cd to root folder of project
- Run `make gen_env`
- Run `make sync`
- Run app via IDE
- Enjoy!

## How to init project

### 1. Init Project
- Run `make gen_env`
- Fill the JSON values in the [setting_initial_config.md](setting_initial_config.md) file
- Run `make init`

### 2. Config Firebase

- Android: Paste your google services files to:
    - [Develop](android/app/src/develop)
    - [Qa](android/app/src/qa)
    - [Staging](android/app/src/staging)
    - [Production](android/app/src/production)
- iOS: Paste your google services files to:
    - [Develop](ios/config/develop)
    - [Qa](ios/config/qa)
    - [Staging](ios/config/staging)
    - [Production](ios/config/production)

### 3. Config Lefthook (optional)

- Install lefthook
- Run `lefthook install`
- Update commit message rule: [commit-msg.sh](.lefthook/commit-msg/commit-msg.sh) and [check_commit_message.sh](tools/check_commit_message.sh)
- Update branch name rule: [pre-commit.sh](.lefthook/pre-commit/pre-commit.sh) and [bitbucket-pipelines/pull-requests](bitbucket-pipelines.yml)

### 4. Config Fastlane (optional)
- Install Fastlane
- Run `make fastlane_update_plugins`
- Put the .p8 file in folder [ios](ios)
- Update config values in:
  - [ios/Fastfile](ios/fastlane/Fastfile)
  - [android/Fastfile](android/fastlane/Fastfile)
  - [.env.default](.env.default)
