Fetch the data from the [FIGMA_LINK], then based on the codebase and existing pages, write the code for the lib/ui/page/[snake_case_screen_name] screen.

## Steps:

1. Use get_code to fetch all data of the screen in the [FIGMA_LINK]

2. Search all strings in the [FIGMA_LINK] and add the appropriate strings to lib/resource/l10n/intl_ja.arb (no need to translate to other languages and do not add strings that can be dynamic data), later when coding UI use l10n.<key>. 
   - Key should be in camelCase. If the string already exists in intl_ja.arb, reuse it.
   - Key name should be translated from value to English. Ex: "ifYouWishToCancelAfter24HoursPleaseCallTheOwnerDirectly": "24時間以降のキャンセルはサロンへ直接お電話ください", "jp": "JP"

3. Search all images in the Figma design and check assets/images folder:
   - If matching file exists: Use it with CommonImage(lib/ui/component/ui_kit/common_image.dart) for next step
     - For .svg files: Use `CommonImage.svg()` constructor
     - For .png files: Use `CommonImage.asset()` constructor
   - If no matching file exists: Do not download the image to assets/images folder and do not use the image in the UI code

4. Based on the data from the get_code command above, complete the {PascalCaseScreenName}Page, {PascalCaseScreenName}ViewModel, {PascalCaseScreenName}State classes
  - For {PascalCaseScreenName}Page, follow the instructions:
    - Do not code the status bar UI
    - Use CommonImage with path image.<image_name>, do not use Icon widget
    - Use CommonImage.svg() for .svg files and CommonImage.asset() for .png files
    - Use CommonText for text with `style: style(color: color.<color_name>, fontSize: <font_size>.rps)` for text style. If the <color_name> does not exist in AppColors(lib/resource/app_colors.dart), use Color(0xFF<hex_color>) instead
    - Use l10n.<key> for strings
    - Use `.rps` for fontSize, width, height, other dimensions
    - Use CommonScaffold for the page scaffold
    - For the UI of detail pages, edit pages, or confirmation pages is too long, consider wrapping with SingleChildScrollView
    - If the UI has a scrollable widget like below, wrap the widget with CommonScrollbarWithIosStatusBarTapDetector(lib/ui/component/ui_kit/common_scrollbar_with_ios_status_bar_tap_detector.dart)
      - 'SingleChildScrollView'
      - 'ListView'
      - 'GridView'
      - 'NestedScrollView'
      - 'CustomScrollView'
      - 'CommonPagedGridView'
      - 'CommonPagedListView'
    - Prioritize using flutter_hooks: useScrollController() for scroll controllers, useTextEditingController() for text editing controllers,...
    - Prioritize using the common widgets available in lib/ui/component/ folder
      - CommonAppBar instead of AppBar
      - CommonDivider instead of Divider
      - CommonImage instead of Image, Icon or SvgPicture
      - CommonScaffold instead of Scaffold
      - CommonText instead of Text
      - CommonProgressIndicator instead of CircularProgressIndicator
    - For input components like TextField, prioritize creating fields in the state and managing them in the ViewModel instead of using controllers directly in the Page
    - Follow the spec in the *_spec.md file in [snake_case_screen_name] folder
    - If the spec file specifies a component that does not exist, create it in lib/ui/component/ folder
    - Avoid duplicated code, create reusable widgets in lib/ui/component/ folder
    - One file has only one public widget class, do not create multiple public widget classes in one file, private classes are allowed
    - Text color must be same as Figma design
    - Font size must be same as Figma design
    - Layout/widget alignment must be the same as design
  - For {PascalCaseScreenName}State, prefer using @Default() to set default values for all properties
  - For {PascalCaseScreenName}ViewModel:
    - Follow the spec in the *_spec.md file in [snake_case_screen_name] folder
    - `ref.appPreferences`, `ref.appApiService`, `ref.appDatabase` in ViewModel classes must be wrapped in `runCatching`
    - ViewModels must use `runCatching` for error handling
    - Validation logic must be declared in AppUtil(lib/common/util/app_util.dart)

5. Write golden tests and generate snapshots based on the instructions in .prompt_templates/golden_test/generate_golden_tests.md file with PAGE_FILE_PATH: lib/ui/page/[snake_case_screen_name]/[snake_case_screen_name]_page.dart

## Notes:

- Do not comment
- Do not modify any existing strings, colors or images
- Use make_fb instead of dart run build_runner build
- Use MVVM and Riverpod for state management

## Variables:
- [FIGMA_LINK]: [YOUR_FIGMA_LINK]
- [snake_case_screen_name]: [SNAKE_CASE_SCREEN_NAME]

Note: Output must be the same as the design in the attached image.