import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockMyProfileViewModel extends StateNotifier<CommonState<MyProfileState>>
    with Mock
    implements MyProfileViewModel {
  MockMyProfileViewModel(super.state);
}

void main() {
  group('others', () {
    testGoldens(
      'when current user is not vip member',
      (tester) async {
        await tester.testWidget(
          filename: 'my_profile_page/when current user is not vip member',
          widget: const MyProfilePage(),
          overrides: [
            myProfileViewModelProvider.overrideWith(
              (_) => MockMyProfileViewModel(
                const CommonState(
                  data: MyProfileState(),
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
          filename: 'my_profile_page/when current user is vip member',
          widget: const MyProfilePage(),
          overrides: [
            myProfileViewModelProvider.overrideWith(
              (_) => MockMyProfileViewModel(
                const CommonState(
                  data: MyProfileState(),
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
