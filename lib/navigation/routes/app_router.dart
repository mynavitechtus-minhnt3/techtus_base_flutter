import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../index.dart' hide PageInfo;

final appRouterProvider = Provider<AppRouter>(
  (ref) => getIt.get<AppRouter>(),
);

// ignore_for_file:prefer-single-widget-per-file
@AutoRouterConfig(
  replaceInRouteName: 'Page,Route',
)
@LazySingleton()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  static const duration = Duration(milliseconds: 300);
  // ignore: prefer_named_parameters
  Widget bottomUpTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    );
  }

  CustomRoute<void> buildCustomRoute({
    required PageInfo page,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)? transitionsBuilder,
    List<AutoRoute>? children,
  }) {
    return CustomRoute(
      page: page,
      transitionsBuilder: transitionsBuilder ?? bottomUpTransitionBuilder,
      fullscreenDialog: true,
      barrierDismissible: false,
      duration: duration,
      reverseDuration: duration,
      children: children,
    );
  }

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page),
        buildCustomRoute(page: LoginRoute.page, transitionsBuilder: TransitionsBuilders.fadeIn),
        buildCustomRoute(
            page: MainRoute.page,
            transitionsBuilder: TransitionsBuilders.fadeIn,
            children: [
              AutoRoute(
                page: HomeTab.page,
                maintainState: true,
                children: [
                  AutoRoute(page: HomeRoute.page, initial: true),
                ],
              ),
              AutoRoute(
                page: MyProfileTab.page,
                maintainState: true,
                children: [
                  AutoRoute(page: MyProfileRoute.page, initial: true),
                  AutoRoute(page: SettingRoute.page), // remove after running `make init` 
                ],
              ),
            ]),
        AutoRoute(page: RegisterRoute.page), // remove after running `make init`
        AutoRoute(page: ChatRoute.page), // remove after running `make init`
        AutoRoute(page: AllUsersRoute.page), // remove after running `make init`
        AutoRoute(page: LoadMoreExampleRoute.page), // remove after running `make init`
      ];
}

@RoutePage(name: 'HomeTab')
class HomeTabPage extends AutoRouter {
  const HomeTabPage({super.key});
}

@RoutePage(name: 'MyProfileTab')
class MyProfileTabPage extends AutoRouter {
  const MyProfileTabPage({super.key});
}
