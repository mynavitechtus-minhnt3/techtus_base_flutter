## Common rules
1. Avoid names that are too short like `a`, `x`, `y`, …
2. Names should reflect the purpose or meaning, not be vague.
3. Follow correct English grammar and word order
    * BAD: `idUser`, `titlePopup`, `colorText`
    * GOOD: `userId`, `popupTitle`, `textColor`
4. Follow correct capitalization rules
    * BAD: `APIClient`, `HTTPClient`, `appIos`
    * GOOD: `ApiClient`, `HttpClient`, `appIOS`
5. All naming must follow the same convention consistently throughout the entire project

## Naming Convention

1. Naming variables, constants, parameters
    * must be in camelCase
    * Local variables declared inside methods, functions do not need to be prefixed with `_`
    * Constants do not need to be prefixed with `k`
        * GOOD: `maxValue`, `separator`, `maxLength`
        * BAD: `kMaxValue`, `kSeparator`, `kMaxLength`
    * Do not name variables using abbreviations (e.g., timeInMillis)
        * GOOD: `timestampInMillisecond`, `button`, `count`
        * BAD: `timestampInMillis`, `btn`, `cnt`
    * If there is a unit, include the unit as a postfix
        * GOOD: `timestampInSecond`, `timestampInMillisecond`, `distanceInCm`, `distanceInMeter`
        * BAD: `timestamp`, `distance`, `userWeight`
    * See more common mistakes in the section: [Common rules](#common-rules)

2. Naming functions, methods
    * must be in camelCase
    * Should be verb + complement (imperative style).
        * GOOD: `calculateDistance`, `calculateTime`
        * BAD: `distance`, `time`
    * Getter → should describe the property, not the action.
        * GOOD: `name`, `age`
        * BAD: `getName`, `getAge`
    * Setter → should describe the action, not the property.
        * GOOD: `setName`, `setAge`
        * BAD: `name`, `age`
    * Booleans → is/has/can/should/will
        * GOOD: `isLoading`, `hasData`, `canLogin`, `shouldLogin`, `willLogin`
        * BAD: `loading`, `data`, `login`, `login`, `login`
    * See more common mistakes in the section: [Common rules](#common-rules)

3. Naming classes, enums, interfaces, mixins, typedefs
    * must be in PascalCase
    * Mixins must end with `Mixin`
        * GOOD: `CommonMixin`, `AuthMixin`
        * BAD: `Common`, `Auth`
    * Abstract classes / interfaces → do not add `I` prefix. Use the original meaningful name.
        * GOOD: `CommonInterface`, `AuthInterface`
        * BAD: `ICommonInterface`, `IAuthInterface`
    * See more common mistakes in the section: [Common rules](#common-rules)

4. Naming files, folders
    * must be in snake_case
    * See more common mistakes in the section: [Common rules](#common-rules)

5. Naming colors in the AppColor class
    * Follow the name of the color in the design
        * GOOD: `primaryBackground`, `primaryText`
        * BAD: `White1`, `White2`
    * Do not append the opacity to the color name
        * GOOD: `primaryBackground`, `primaryText`
        * BAD: `primaryBackground50%`, `primaryText50`

6. Naming L10n keys
    * must be in camelCase
    * The meaning of a key and its corresponding value must match.
        * GOOD: { "enterYourEmail": "Enter your email" }
        * BAD: { "enterYourEmail": "Password of user" }

7. Naming Assets (Images, Audios, Videos)
    * must be in snake_case
    * SVGs should start with `icon_`, other images should start with `image_`
        * GOOD: `icon_add_photo.svg`, `image_poodle.png`
        * BAD: `image_poodle.svg`, `icon_add.png`
    * Use descriptive names, avoid abbreviations
        * GOOD: `icon_calendar.svg`, `icon_notification.svg`
        * BAD: `icon_cal.svg`, `icon_notif.svg`
    * Include variant suffixes when needed
        * GOOD: `icon_request_active.svg`, `icon_request_inactive.svg`
        * BAD: `icon_request1.svg`, `icon_request2.svg`

8. Naming Pages, Providers and State Management
    * Follow the pattern: `{Feature}Page`, `{Feature}ViewModel`, `{Feature}State`
    * Provider variables must end with `Provider`
        * GOOD: `currentUserProvider`, `unreadNotificationsCountProvider`
        * BAD: `currentUser`, `unreadNotificationsCount`
    * Providers of ViewModels should match: `{feature}ViewModelProvider`
    * StateNotifier classes must end with `ViewModel` 
        * GOOD: `MainViewModel`, `UserViewModel`
        * BAD: `MainNotifier`, `UserNotifier`
    * State classes must end with `State`
        * GOOD: `MainState`, `UserState`
        * BAD: `MainData`, `UserData`
    * Provider names should describe the data/service they provide clearly
        * GOOD: `currentUserProvider`, `unreadNotificationsCountProvider`
        * BAD: `userProvider`, `countProvider`

9. Testing
    * Test files must end with `_test.dart`
    * Only 2 test groups are allowed: "design" and "others"
    * Test case filename in "design" group must match the expected image name in "design/" folder
