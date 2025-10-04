import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockHomeViewModel extends StateNotifier<CommonState<HomeState>>
    with Mock
    implements HomeViewModel {
  MockHomeViewModel(super.state);
}

void main() {
  group('others', () {
    testGoldens(
      'when conversationList is empty',
      (tester) async {
        await tester.testWidget(
          filename: 'home_page/when conversationList is empty',
          widget: const HomePage(),
          overrides: [
            homeViewModelProvider.overrideWith(
              (_) => MockHomeViewModel(
                const CommonState(
                  data: HomeState(),
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
      'when conversationList is not empty',
      (tester) async {
        await tester.testWidget(
          filename: 'home_page/when conversationList is not empty',
          widget: const HomePage(),
          onCreate: (tester, key) async {
            final textFieldFinder = find.byType(TextField).isDescendantOfKeyIfAny(key);
            expect(textFieldFinder, findsOneWidget);

            await tester.enterText(textFieldFinder, 'dog');
          },
          overrides: [
            homeViewModelProvider.overrideWith(
              (_) => MockHomeViewModel(
                const CommonState(
                  data: HomeState(conversationList: [
                    FirebaseConversationData(id: '1'),
                    FirebaseConversationData(id: '2'),
                  ]),
                ),
              ),
            ),
            currentUserProvider.overrideWith((ref) => const FirebaseUserData(
                  id: '1',
                  email: 'duynn@gmail.com',
                )),
            conversationNameProvider.overrideWith(
              (ref, conversationId) => conversationId == '1' ? 'Dog, Cat' : 'Fish',
            ),
          ],
        );
      },
    );

    testGoldens(
      'when current user is vip member',
      (tester) async {
        await tester.testWidget(
          filename: 'home_page/when current user is vip member',
          widget: const HomePage(),
          overrides: [
            homeViewModelProvider.overrideWith(
              (_) => MockHomeViewModel(
                const CommonState(
                  data: HomeState(),
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
