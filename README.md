# YOUR_PROJECT_NAME

The simple Flutter project

## Getting Started

### Requirements

- Flutter SDK: 3.35.1
- CocoaPods: 1.16.2

### How to run app

- cd to root folder of project
- Run `make gen_env`
- Run `make sync`
- Run app via IDE
- Enjoy!

## Starting new project

### 1. Config multi-flavors and Firebase

- Change flavor settings:
    - Replace all `jp.flutter.app` by your project bundle id (application id)
    - Config flavors for Android at [build.gradle](android/build.gradle)
        - Application name: find and change values of: `manifestPlaceholders["applicationName"]`
        - Version name: find and change values of: `versionName`
        - Version code: find and change values of: `versionCode`
    - Config flavors for iOS at: 
        - [Develop.xcconfig](ios/Flutter/Develop.xcconfig)
        - [Qa.xcconfig](ios/Flutter/Qa.xcconfig)
        - [Staging.xcconfig](ios/Flutter/Staging.xcconfig)
        - [Production.xcconfig](ios/Flutter/Production.xcconfig) 

- Config Firebase
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

### 2. Secrets configuration

- Define secret constants in [env.dart](lib/common/env.dart) and JSON files in folder [dart_defines](dart_defines) including:
    - dart_defines/develop.json
    - dart_defines/qa.json
    - dart_defines/staging.json
    - dart_defines/production.json

For example:
```
{
  "FLAVOR": "develop",
  "APP_BASIC_AUTH_NAME": "admin",
  "APP_BASIC_AUTH_PASSWORD": "admin"
}
```

### 3. Other configs

- `designDeviceWidth`, `designDeviceHeight`, `materialAppTitle`, `taskMenuMaterialAppColor`, `systemUiOverlay`, `mobileOrientation`, `tabletOrientation` in [constant.dart](lib/common/constant.dart)

### 4. Update README.md

- [YOUR_PROJECT_NAME](#YOUR_PROJECT_NAME) and the project description
- [Upgrade Flutter](#upgrade-flutter) if needed

### 5. Setup Fastlane (optional)
- Install Fastlane
- Run `make fastlane_update_plugins`
- Create a single file `.env.default` at the project root
- Paste this into the file
```
SLACK_HOOKS_URL=https://hooks.slack.com/services/xxx
ISSUER_ID=xxx
FIREBASE_TOKEN=1//xxx
MENTIONS=@minhnt3
MESSAGE=Xin các anh chị tester nhẹ tay giúp!
DEV_FLAVOR=develop
QA_FLAVOR=qa
STG_FLAVOR=staging
```
- Put the .p8 file in folder [ios](ios)
- Update config values in [ios/Fastfile](ios/fastlane/Fastfile) and [android/Fastfile](android/fastlane/Fastfile)

### 6. Setup Lefthook (optional)

- Replace all text: `NFT` by `YOUR_PROJECT_CODE` in:
    - Commit message rule: [commit-msg.sh](.lefthook/commit-msg/commit-msg.sh) and [check_commit_message.sh](tools/check_commit_message.sh)
    - Branch name rule: [pre-commit.sh](.lefthook/pre-commit/pre-commit.sh) and [bitbucket-pipelines/pull-requests](bitbucket-pipelines.yml)
- Run `lefthook install`

## Note

### 1. Upgrading Flutter
- Please update these files when upgrading Flutter version:
    - [README.md](#requirements)
    - [bitbucket-pipelines.yml](bitbucket-pipelines.yml)
    - [Jenkinsfile](Jenkinsfile)
    - [codemagic.yaml](codemagic.yaml)
    - [ci.yaml](.github/workflows/ci.yaml)
    - [cd_develop.yaml](.github/workflows/cd_develop.yaml)
    - [cd_qa.yaml](.github/workflows/cd_qa.yaml)
    - [cd_staging.yaml](.github/workflows/cd_staging.yaml)
    - [cd_production.yaml](.github/workflows/cd_production.yaml)
