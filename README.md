## Getting Started

### Requirements

- Flutter SDK: 3.35.4
- CocoaPods: 1.16.2
- JVM: 17+

### How to run app

- cd to root folder of project
- Run `make gen_env`
- Run `make sync`
- Run app via IDE
- Enjoy!

## How to use this codebase

// table of content
- [1. Init Project](#1-init-project)
- [2. Config Firebase](#2-config-firebase)
- [3. Config Lefthook](#3-config-lefthook)
- [4. Config Fastlane](#4-config-fastlane)

### 1. Init Project
- Run `make gen_env` to generate [setting_initial_config.md](setting_initial_config.md) file
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

### 3. Config Lefthook

- Install lefthook
- Run `lefthook install`
- Update commit message rule: [commit-msg.sh](.lefthook/commit-msg/commit-msg.sh) and [check_commit_message.sh](tools/check_commit_message.sh)
- Update branch name rule: [pre-commit.sh](.lefthook/pre-commit/pre-commit.sh) and [bitbucket-pipelines/pull-requests](bitbucket-pipelines.yml)

### 4. Config Fastlane
- Install Fastlane
- Run `make fastlane_update_plugins`
- Put the .p8 file in folder [ios](ios)
- Update config values in:
  - [ios/Fastfile](ios/fastlane/Fastfile)
  - [android/Fastfile](android/fastlane/Fastfile)
  - [.env.default](.env.default)

### 5. Generate all pages
- Fill all pages need to be generated in [lib/ui/page/input_pages.md](lib/ui/page/input_pages.md) file
- Run `make gap` to generate all empty pages including `*.freezed.dart`, `*.gr.dart` files without running the command `make fb`

### 6. Generate app colors
- Make sure Figma MCP is working
- Use the [generate_app_colors prompt](.prompt_templates/ui/generate_app_colors.md) with [YOUR_FIGMA_LINK] replaced by your Figma link to generate app colors in [lib/resource/app_colors.dart](lib/resource/app_colors.dart) file
