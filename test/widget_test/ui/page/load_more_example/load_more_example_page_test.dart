import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockLoadMoreExampleViewModel extends StateNotifier<CommonState<LoadMoreExampleState>>
    with Mock
    implements LoadMoreExampleViewModel {
  MockLoadMoreExampleViewModel(super.state);
}

LoadMoreExampleViewModel _buildLoadMoreExampleViewModel(CommonState<LoadMoreExampleState> state) {
  final vm = MockLoadMoreExampleViewModel(state);

  when(() => vm.fetchUsers(isInitialLoad: any(named: 'isInitialLoad'))).thenAnswer((_) async {});

  return vm;
}

void main() {
  group('others', () {
    testGoldens(
      'when fetching background image failed',
      (tester) async {
        await runZonedGuarded(
          () async {
            /// Exception to cause errors on purpose also causes errors in this test case, which are mixed with Golden errors.
            /// Therefore, Exception errors in this test case are ignored and only cause Golden errors.
            final oldCallback = FlutterError.onError;
            FlutterError.onError = (details) {
              if (details.exception is HttpExceptionWithStatus) {
                return;
              }
              oldCallback?.call(details);
            };

            await tester.testWidget(
              filename: 'load_more_example_page/when fetching background image failed',
              widget: LoadMoreExamplePage(cacheManager: MockInvalidCacheManager()),
              overrides: [
                loadMoreExampleViewModelProvider.overrideWith(
                  (_) => _buildLoadMoreExampleViewModel(
                    CommonState(
                      data: LoadMoreExampleState(),
                    ),
                  ),
                ),
              ],
              customPump: (t) => t.pump(),
            );
          },
          (error, stack) {},
        );
      },
    );

    testGoldens(
      'when `isShimmerLoading` is true',
      (tester) async {
        await tester.testWidget(
          filename: 'load_more_example_page/when `isShimmerLoading` is true',
          widget: LoadMoreExamplePage(cacheManager: MockCacheManager()),
          overrides: [
            loadMoreExampleViewModelProvider.overrideWith(
              (_) => _buildLoadMoreExampleViewModel(
                CommonState(
                  data: LoadMoreExampleState(
                    isShimmerLoading: true,
                  ),
                ),
              ),
            ),
          ],
          customPump: (t) => t.pump(),
        );
      },
    );

    testGoldens(
      'when `users` is empty',
      (tester) async {
        await tester.testWidget(
          filename: 'load_more_example_page/when `users` is empty',
          widget: LoadMoreExamplePage(cacheManager: MockCacheManager()),
          overrides: [
            loadMoreExampleViewModelProvider.overrideWith(
              (_) => _buildLoadMoreExampleViewModel(
                CommonState(
                  data: LoadMoreExampleState(),
                ),
              ),
            ),
          ],
          customPump: (t) => t.pump(),
        );
      },
    );

    testGoldens(
      'when `users` is not empty',
      (tester) async {
        await tester.testWidget(
          filename: 'load_more_example_page/when `users` is not empty',
          widget: LoadMoreExamplePage(cacheManager: MockCacheManager()),
          overrides: [
            loadMoreExampleViewModelProvider.overrideWith(
              (_) => _buildLoadMoreExampleViewModel(
                CommonState(
                  data: LoadMoreExampleState(
                    users: LoadMoreOutput(
                      data: List.generate(
                        Constant.itemsPerPage,
                        (index) => ApiUserData(
                          id: 1,
                          email: 'nghiand1@nals.vn',
                          birthday: DateTime(2000, 1, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          customPump: (t) => t.pump(const Duration(seconds: 1)),
        );
      },
    );
  });
}
