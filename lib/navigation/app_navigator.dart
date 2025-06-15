// ignore_for_file: avoid_using_unsafe_cast
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart' as m;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../index.dart';

final appNavigatorProvider = Provider<AppNavigator>(
  (ref) => getIt.get<AppNavigator>(),
);

@LazySingleton()
class AppNavigator {
  AppNavigator(
    this._appRouter,
  );

  final tabRoutes = const [
    ContactListTab(),
    MyPageTab(),
  ];

  TabsRouter? tabsRouter;

  final AppRouter _appRouter;

  // ignore: avoid_dynamic
  final _popups = <String, Completer<dynamic>>{};

  StackRouter? get _currentTabRouter => tabsRouter?.stackRouterOfIndex(currentBottomTab);

  StackRouter get _currentTabRouterOrRootRouter => _currentTabRouter ?? _appRouter;

  m.BuildContext get _rootRouterContext => _appRouter.navigatorKey.currentContext!;

  m.BuildContext? get _currentTabRouterContext => _currentTabRouter?.navigatorKey.currentContext;

  m.BuildContext get _currentTabContextOrRootContext =>
      _currentTabRouterContext ?? _rootRouterContext;

  int get currentBottomTab {
    if (tabsRouter == null) {
      throw 'Not found any TabRouter';
    }

    return tabsRouter?.activeIndex ?? 0;
  }

  bool get canPopSelfOrChildren => _appRouter.canPop();

  bool get isUseRootNavigator {
    final stack = _appRouter.current.router.stack;

    if (_popups.isNotEmpty && _popups.keys.any((key) => !key.contains('SnackBar'))) return true;

    if (!stack.any((r) => r.routeData.name == _mainRoute)) {
      return true;
    }

    if (stack.length <= 1) return false;

    final previousRoute = stack[stack.length - 2];

    if (checkExistsRouteInStack(
      routeName: _mainRoute,
      routerData: previousRoute.routeData,
    )) {
      return !tabRoutes.any((tab) => tab.routeName == previousRoute.routeData.name);
    }

    return true;
  }

  bool checkExistsRouteInStack({
    // ignore: strict_raw_type
    required RouteData routerData,
    required String routeName,
  }) {
    final currentSegments = routerData.router.currentSegments;

    return currentSegments.any((route) => route.name == routeName);
  }

  String get _mainRoute => 'MainRoute';

  String getCurrentRouteName() =>
      AutoRouter.of(isUseRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext)
          .current
          .name;

  // ignore: strict_raw_type
  RouteData getCurrentRouteData() =>
      AutoRouter.of(isUseRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext)
          .current;

  void popUntilRootOfCurrentBottomTab() {
    if (tabsRouter == null) {
      throw 'Not found any TabRouter';
    }

    if (_currentTabRouter?.canPop() == true) {
      if (Config.enableNavigatorObserverLog) {
        Log.d('popUntilRootOfCurrentBottomTab');
      }
      _currentTabRouter?.popUntilRoot();
    }
  }

  void navigateToBottomTab({required int index, bool notify = true}) {
    if (tabsRouter == null) {
      throw 'Not found any TabRouter';
    }

    if (Config.enableNavigatorObserverLog) {
      Log.d('navigateToBottomTab with index = $index, notify = $notify');
    }
    tabsRouter?.setActiveIndex(index, notify: notify);
  }

  // ignore: prefer_named_parameters
  Future<T?> push<T extends Object?>(PageRouteInfo routeInfo, {String? name}) {
    if (Config.enableNavigatorObserverLog) {
      Log.d('push $routeInfo');
    }

    return _appRouter.push<T>(routeInfo.copyWith(name: name));
  }

  Future<void> pushAll(List<PageRouteInfo> listRouteInfo) {
    if (Config.enableNavigatorObserverLog) {
      Log.d('pushAll $listRouteInfo');
    }

    return _appRouter.pushAll(listRouteInfo);
  }

  Future<T?> replace<T extends Object?>(PageRouteInfo routeInfo) {
    _popups.clear();
    if (Config.enableNavigatorObserverLog) {
      Log.d('replace by $routeInfo');
    }

    return _appRouter.replace<T>(routeInfo);
  }

  // ignore: prefer_named_parameters
  Future<void> replaceAll(
    List<PageRouteInfo> listRouteInfo, {
    bool updateExistingRoutes = true,
  }) {
    _popups.clear();
    if (Config.enableNavigatorObserverLog) {
      Log.d('replaceAll by $listRouteInfo');
    }

    return _appRouter.replaceAll(
      listRouteInfo,
      updateExistingRoutes: updateExistingRoutes,
    );
  }

  Future<bool> pop<T extends Object?>({
    T? result,
  }) async {
    final useRootNavigator = isUseRootNavigator;
    if (Config.enableNavigatorObserverLog) {
      Log.d('pop with result = $result, useRootNavigator = $useRootNavigator');
    }

    return useRootNavigator
        ? _appRouter.maybePop<T>(result)
        : _currentTabRouterOrRootRouter.maybePop<T>(result);
  }

  // ignore: prefer_named_parameters
  Future<T?> popAndPush<T extends Object?, R extends Object?>(
    PageRouteInfo routeInfo, {
    R? result,
  }) {
    final useRootNavigator = isUseRootNavigator;
    if (Config.enableNavigatorObserverLog) {
      Log.d(
        'popAndPush $routeInfo with result = $result, useRootNavigator = $useRootNavigator',
      );
    }

    return useRootNavigator
        ? _appRouter.popAndPush<T, R>(
            routeInfo,
            result: result,
          )
        : _currentTabRouterOrRootRouter.popAndPush<T, R>(
            routeInfo,
            result: result,
          );
  }

  void popUntilRoot() {
    final useRootNavigator = isUseRootNavigator;
    if (Config.enableNavigatorObserverLog) {
      Log.d('popUntilRoot, useRootNavigator = $useRootNavigator');
    }

    useRootNavigator ? _appRouter.popUntilRoot() : _currentTabRouterOrRootRouter.popUntilRoot();
  }

  void popUntilRouteName(String routeName) {
    if (Config.enableNavigatorObserverLog) {
      Log.d('popUntilRouteName $routeName');
    }

    _appRouter.popUntilRouteWithName(routeName);
  }

  Future<void> popUntilRouteNameOfCurrentTab({
    required String routeName,
    Object? result,
  }) async {
    if (Config.enableNavigatorObserverLog) {
      Log.d('popUntilRouteNameOfCurrentTab $routeName');
    }
    await _appRouter.popUntilNamedWithResult(routeName: _mainRoute, result: result);
    await Future.delayed(const Duration(milliseconds: 100));
    await _currentTabRouterOrRootRouter.popUntilNamedWithResult(
        routeName: routeName, result: result);
  }

  bool removeUntilRouteName(String routeName) {
    if (Config.enableNavigatorObserverLog) {
      Log.d('removeUntilRouteName $routeName');
    }

    return _appRouter.removeUntil((route) => route.name == routeName);
  }

  bool removeAllRoutesWithName(String routeName) {
    if (Config.enableNavigatorObserverLog) {
      Log.d('removeAllRoutesWithName $routeName');
    }

    return _appRouter.removeWhere((route) => route.name == routeName);
  }

  // ignore: prefer_named_parameters
  Future<void> popAndPushAll(List<PageRouteInfo> listRouteInfo) {
    final useRootNavigator = isUseRootNavigator;
    if (Config.enableNavigatorObserverLog) {
      Log.d('popAndPushAll $listRouteInfo, useRootNavigator = $useRootNavigator');
    }

    return useRootNavigator
        ? _appRouter.popAndPushAll(listRouteInfo)
        : _currentTabRouterOrRootRouter.popAndPushAll(listRouteInfo);
  }

  bool removeLast() {
    if (Config.enableNavigatorObserverLog) {
      Log.d('removeLast');
    }

    return _appRouter.removeLast();
  }

  // ignore: prefer_named_parameters
  Future<T?> showDialog<T extends Object?>(
    CommonPopup popup, {
    bool barrierDismissible = true,
    bool useSafeArea = false,
    bool useRootNavigator = true,
    bool canPop = true,
  }) async {
    if (_popups.containsKey(popup.id)) {
      Log.d('Dialog $popup already shown');

      return _popups[popup.id]!.future as Future<T?>;
    }

    _popups[popup.id] = Completer<T?>();

    return m.showDialog<T>(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      builder: (context) => m.PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          Log.d('Dialog $popup dismissed with result = $result');
          _popups.remove(popup.id);
        },
        canPop: canPop,
        child: popup.builder(context, this),
      ),
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
      useSafeArea: useSafeArea,
    );
  }

  // ignore: prefer_named_parameters
  Future<T?> showGeneralDialog<T extends Object?>(
    CommonPopup popup, {
    Duration transitionDuration = Constant.generalDialogTransitionDuration,
    m.Widget Function(
      m.BuildContext,
      m.Animation<double>,
      m.Animation<double>,
      m.Widget,
    )? transitionBuilder,
    m.Color barrierColor = const m.Color(0x80000000),
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    bool canPop = true,
  }) {
    if (_popups.containsKey(popup.id)) {
      Log.d('GeneralDialog $popup already shown');

      return _popups[popup.id]!.future as Future<T?>;
    }
    _popups[popup.id] = Completer<T?>();

    return m.showGeneralDialog<T>(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
      pageBuilder: (
        m.BuildContext context,
        m.Animation<double> animation1,
        m.Animation<double> animation2,
      ) =>
          m.PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          Log.d('GeneralDialog $popup dismissed with result = $result');
          _popups.remove(popup.id);
        },
        canPop: canPop,
        child: popup.builder(context, this),
      ),
      transitionBuilder: transitionBuilder,
      transitionDuration: transitionDuration,
    );
  }

  // ignore: prefer_named_parameters
  Future<T?> showModalBottomSheet<T extends Object?>(
    CommonPopup popup, {
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    m.Color barrierColor = m.Colors.black54,
    m.Color? backgroundColor,
    bool canPop = true,
  }) {
    if (_popups.containsKey(popup.id)) {
      Log.d('BottomSheet $popup already shown');

      return _popups[popup.id]!.future as Future<T?>;
    }
    _popups[popup.id] = Completer<T?>();

    return m.showModalBottomSheet<T>(
      context: useRootNavigator ? _rootRouterContext : _currentTabContextOrRootContext,
      builder: (context) => m.PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          Log.d('BottomSheet $popup dismissed with result = $result');
          _popups.remove(popup.id);
        },
        canPop: canPop,
        child: popup.builder(context, this),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
    );
  }

  // ignore: prefer_named_parameters
  void showSnackBar(CommonPopup popup, {m.BuildContext? context}) {
    if (_popups.containsKey(popup.id)) {
      Log.d('showSnackBar $popup already shown');

      return;
    }
    _popups[popup.id] = Completer<void>();

    final messengerState = m.ScaffoldMessenger.maybeOf(context ?? _rootRouterContext);
    if (messengerState == null) {
      return;
    }
    messengerState.hideCurrentSnackBar();
    messengerState.showSnackBar(
      popup.builder(context ?? _rootRouterContext, this) as m.SnackBar,
    );
    Future.delayed(Constant.snackBarDuration, () {
      _popups.remove(popup.id);
    });
  }
}

extension RouterUtils<T extends Object?> on StackRouter {
  Future<void> popUntilNamedWithResult({
    required String routeName,
    T? result,
    bool forced = false,
  }) async {
    final targetRouteIndex = stackData.indexWhere((e) => e.name == routeName);

    if (targetRouteIndex == -1) return;

    for (var i = stackData.lastIndex; i > targetRouteIndex; i--) {
      if (i == targetRouteIndex + 1) {
        forced ? pop(result) : await maybePop(result);
      } else {
        forced ? pop() : await maybePop();
      }
    }
  }
}
