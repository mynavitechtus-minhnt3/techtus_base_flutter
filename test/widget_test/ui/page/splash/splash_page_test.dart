import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockSplashViewModel extends StateNotifier<CommonState<SplashState>>
    with Mock
    implements SplashViewModel {
  MockSplashViewModel(super.state) {
    when(() => init()).thenAnswer((_) async {});
  }
}

void main() {
  group(
    'others',
    () {
      testGoldens(
        'default state',
        (tester) async {
          await tester.testWidget(
            filename: 'splash_page/default_state',
            widget: const SplashPage(),
            overrides: [
              splashViewModelProvider.overrideWith((ref) => MockSplashViewModel(
                    const CommonState(
                      data: SplashState(),
                    ),
                  )),
            ],
          );
        },
      );
    },
  );
}
