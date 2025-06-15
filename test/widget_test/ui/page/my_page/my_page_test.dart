import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockMyPageViewModel extends StateNotifier<CommonState<MyPageState>>
    with Mock
    implements MyPageViewModel {
  MockMyPageViewModel(super.state);
}

void main() {
  group('MyPagePage', () {
    testGoldens(
      'when current user is not vip member',
      (tester) async {
        await tester.testWidget(
          filename: 'my_page_page/when_current_user_is_not_vip_member',
          widget: const MyPage(),
          overrides: [
            myPageViewModelProvider.overrideWith(
              (_) => MockMyPageViewModel(
                const CommonState(
                  data: MyPageState(),
                ),
              ),
            ),
            currentUserProvider.overrideWith((ref) => const FirebaseUserData(
                  id: '1',
                  email: 'ntminhdn@gmail.com',
                )),
          ],
        );
      },
    );

    testGoldens(
      'when current user is vip member',
      (tester) async {
        await tester.testWidget(
          filename: 'my_page_page/when_current_user_is_vip_member',
          widget: const MyPage(),
          overrides: [
            myPageViewModelProvider.overrideWith(
              (_) => MockMyPageViewModel(
                const CommonState(
                  data: MyPageState(),
                ),
              ),
            ),
            currentUserProvider.overrideWith((ref) => const FirebaseUserData(
                  id: '1',
                  email: 'ntminhdnlonglonglonglonglong@gmail.com',
                  isVip: true,
                )),
          ],
        );
      },
    );
  });
}
