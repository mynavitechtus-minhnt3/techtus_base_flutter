import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../index.dart';

abstract class BaseStatefulPageState<
    ST extends BaseState,
    VM extends BaseViewModel<ST>,
    P extends ProviderListenable<CommonState<ST>>,
    W extends StatefulHookConsumerWidget> extends ConsumerState<W> {
  P get provider;
  ScreenViewEvent get screenViewEvent;

  AppNavigator get nav => ref.read(appNavigatorProvider);

  VM get vm;

  ExceptionHandler get exceptionHandler => ref.read(exceptionHandlerProvider);

  @override
  Widget build(BuildContext context) {
    AppDimen.init();
    AppColors.of(context);
    l10n = AppString.of(context)!;

    ref.listen(
      provider.select((value) => value.appException),
      (previous, next) async {
        if (previous != next && next != null) {
          await exceptionHandler.handleException(next);
        }
      },
    );

    return FocusDetector(
      key: Key(screenViewEvent.fullKey),
      onVisibilityGained: () => onVisibilityChanged(),
      child: Stack(
        children: [
          buildPage(context),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) => Visibility(
              visible: ref.watch(provider.select((value) => value.isLoading)),
              child: buildPageLoading(),
            ),
          ),
        ],
      ),
    );
  }

  void onVisibilityChanged() {
    ref.analyticsHelper.logScreenView(screenViewEvent);
  }

  Widget buildPageLoading() => const CommonProgressIndicator();

  Widget buildPage(BuildContext context);
}
