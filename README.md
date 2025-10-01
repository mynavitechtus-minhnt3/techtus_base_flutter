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
- Make sure Figma MCP is running
- Use the [generate_app_colors prompt](.prompt_templates/ui/generate_app_colors.md) with [YOUR_FIGMA_LINK] replaced by your Figma link to generate app colors in [lib/resource/app_colors.dart](lib/resource/app_colors.dart) file

### 7. Generate all APIs (methods and models)
- Place your OpenAPI JSON specification file in the `docs/api_doc` folder
- Run `make gen_api` to generate API methods and model classes with default settings (append mode, using docs/api_doc)
- Run `make fb` to generate the necessary build files after API generation

#### Advanced Usage:
```bash
# Basic usage (uses default input_path=docs/api_doc, replace=false)
make gen_api

# Generate specific APIs only
make gen_api apis=get_v1/users,post_v1/auth,get_v2/profile

# Replace all existing generated code instead of appending
make gen_api replace=true

# Use custom input path
make gen_api input_path=custom/swagger/docs

# Use custom output path
make gen_api output_path=lib/custom/api

# Combine multiple options
make gen_api input_path=swagger/docs replace=true apis=get_v1/search,post_v2/city
```

#### What gets generated:
- **API Methods**: Added to `lib/data_source/api/app_api_service.dart` (after the generated marker)
- **Model Classes**: Created in `lib/model/api/` folder with Freezed annotations
- **Nested Classes**: Automatically generated for complex response structures

#### Notes:
- The tool uses `_authAppServerApiClient` by default for all APIs
- Manually modify methods that should use `_noneAuthAppServerApiClient` if needed
- Generated code is marked with `// GENERATED CODE - DO NOT MODIFY OR DELETE THIS COMMENT`
- In append mode (default), new methods are added without removing existing ones
- In replace mode, all code below the marker is replaced

### 8. Generate UI from Figma
- Make sure Figma MCP is running
- Download all images used in the Figma design to assets/images folder
- Run `make ga` to generate all assets in [app_images.dart](lib/resource/app_images.dart) file
- Fill screen spec in *_spec.md file in the page folder
- Attach the image (.png) of design from Figma to the /design folder (same level as the *_test.dart file in the widget_test folder)
- Use the [generate_ui_from_figma prompt](.prompt_templates/ui/generate_ui_from_figma.md) with:
 - [YOUR_FIGMA_LINK] replaced by your Figma link to generate
 - [SNAKE_CASE_SCREEN_NAME] replaced by your screen name in snake_case
 - Attach the image (.png) of design from Figma to the prompt
