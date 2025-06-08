import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockSettingViewModel extends StateNotifier<CommonState<SettingState>>
    with Mock
    implements SettingViewModel {
  MockSettingViewModel(super.state);
}

void main() {
  group('SettingPage', () {
    group('test', () {
      void _baseTestGoldens({
        required LanguageCode languageCode,
        required bool isDarkMode,
      }) {
        testGoldens(
          'when theme is ${isDarkMode ? 'dark' : 'light'} and language is ${languageCode.localeCode}',
          (tester) async {
            await tester.testWidget(
              filename:
                  'setting/when_theme_is_${isDarkMode ? 'dark' : 'light'}_and_language_is_$languageCode',
              widget: const SettingPage(),
              isDarkMode: isDarkMode,
              locale: languageCode.locale,
              overrides: [
                settingViewModelProvider.overrideWith(
                  (_) => MockSettingViewModel(
                    const CommonState(
                      data: SettingState(),
                    ),
                  ),
                ),
                isDarkModeProvider.overrideWith((_) => isDarkMode),
                languageCodeProvider.overrideWith((_) => languageCode),
              ],
            );
          },
        );
      }

      _baseTestGoldens(languageCode: LanguageCode.en, isDarkMode: false);
      _baseTestGoldens(languageCode: LanguageCode.ja, isDarkMode: false);
      _baseTestGoldens(languageCode: LanguageCode.en, isDarkMode: true);
      _baseTestGoldens(languageCode: LanguageCode.ja, isDarkMode: true);
    });
  });
}
