Fetch the data from the [FIGMA_LINK], then based on the codebase and existing pages, write the code for the lib/ui/page/[snake_case_screen_name] screen.

## Steps:

1. Use get_code to fetch all data of the screen in the [FIGMA_LINK]

2. Search all strings in the [FIGMA_LINK] and add the appropriate strings to lib/resource/l10n/intl_ja.arb (no need to translate to other languages and do not add strings that can be dynamic data), later when coding UI use l10n.<key>

3. Search all images in the Figma design and check assets/images folder:

   - If matching file exists: Use it with CommonImage(lib/ui/component/ui_kit/common_image.dart) for next step
     - For .svg files: Use `CommonImage.svg()` constructor
     - For .png files: Use `CommonImage.asset()` constructor
   - If no matching file exists: Create empty image file with corresponding name in assets/images folder (do not create images in the status bar)

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
    - Avoid duplicated code, create reusable widgets in lib/ui/component/ folder
    - Follow the spec in the *_spec.md file in [snake_case_screen_name] folder
    - For input components like TextField, prioritize creating fields in the state and managing them in the ViewModel instead of using controllers directly in the Page
  - For {PascalCaseScreenName}State, prefer using @Default() to set default values for all properties
  - For {PascalCaseScreenName}ViewModel, follow the spec in the *_spec.md file in [snake_case_screen_name] folder

5. Write golden tests and generate snapshots based on the instructions in .prompt_templates/golden_test/generate_golden_tests.md file with PAGE_FILE_PATH: lib/ui/page/[snake_case_screen_name]/[snake_case_screen_name]_page.dart

## Notes:

- Do not comment
- Do not modify any existing strings, colors or images
- Use make_fb instead of dart run build_runner build
- Use MVVM and Riverpod for state management

## Variables:
- [FIGMA_LINK]: [YOUR_FIGMA_LINK]
- [snake_case_screen_name]: [SNAKE_CASE_SCREEN_NAME]
