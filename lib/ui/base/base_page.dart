import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../index.dart';

abstract class BasePage<ST extends BaseState, P extends ProviderListenable<CommonState<ST>>>
    extends HookConsumerWidget {
  const BasePage({super.key});

  P get provider;
  ScreenViewEvent get screenViewEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppDimen.init();
    AppColors.of(context);
    l10n = AppString.of(context)!;

    ref.listen(
      provider.select((value) => value.appException),
      (previous, next) {
        if (previous != next && next != null) {
          handleException(next, ref);
        }
      },
    );

    return FocusDetector(
      key: Key(screenViewEvent.fullKey),
      onVisibilityGained: () => onVisibilityChanged(ref),
      child: Stack(
        children: [
          buildPage(context, ref),
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

  // ignore: prefer_named_parameters
  void onVisibilityChanged(WidgetRef ref) {
    ref.analyticsHelper.logScreenView(screenViewEvent);
  }

  Widget buildPageLoading() => const CommonProgressIndicator();

  // ignore: prefer_named_parameters
  Widget buildPage(BuildContext context, WidgetRef ref);

  // ignore: prefer_named_parameters
  Future<void> handleException(
    AppException appException,
    WidgetRef ref,
  ) async {
    await ref.read(exceptionHandlerProvider).handleException(appException);
  }
}
