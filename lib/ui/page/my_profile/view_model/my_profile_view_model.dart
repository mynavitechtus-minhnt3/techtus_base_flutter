import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../index.dart';

final myProfileViewModelProvider =
    StateNotifierProvider.autoDispose<MyProfileViewModel, CommonState<MyProfileState>>(
  (ref) => MyProfileViewModel(ref),
);

class MyProfileViewModel extends BaseViewModel<MyProfileState> {
  MyProfileViewModel(this._ref)
      : super(
          const CommonState(data: MyProfileState()),
        );

  final Ref _ref;

  Future<void> logout() {
    return runCatching(
      action: () async {
        await _ref.sharedViewModel.logout();
      },
      handleErrorWhen: (_) => false,
    );
  }

  Future<void> deleteAccount() async {
    return runCatching(
      action: () async {
        final userId = _ref.appPreferences.userId;
        await _ref.appPreferences.clearCurrentUserData();
        await _ref.firebaseFirestoreService.deleteUser(userId);
        await _ref.firebaseAuthService.deleteAccount();
        await _ref.nav.replaceAll([const LoginRoute()]);
      },
      handleErrorWhen: (_) => false,
      doOnError: (e) async {
        await _ref.nav.replaceAll([const LoginRoute()]);
      },
    );
  }
}
