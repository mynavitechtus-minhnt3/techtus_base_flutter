import 'package:auto_route/auto_route.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../index.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({required this.initialResource, super.key});

  final InitialResource initialResource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref.listenManual(
        isDarkModeProvider,
        (previous, next) {
          AppThemeSetting.currentAppThemeType = next ? AppThemeType.dark : AppThemeType.light;
        },
        fireImmediately: true,
      );

      return null;
    }, const []);

    final appRouter = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(Constant.designDeviceWidth, Constant.designDeviceHeight),
      builder: (context, _) => Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final isDarkTheme = ref.watch(isDarkModeProvider);
          final languageCode = ref.watch(languageCodeProvider);

          return DevicePreview(
            enabled: Config.enableDevicePreview,
            builder: (_) => MaterialApp.router(
              builder: (context, child) {
                final widget = MediaQuery.withClampedTextScaling(
                  maxScaleFactor: Constant.appMaxTextScaleFactor,
                  minScaleFactor: Constant.appMinTextScaleFactor,
                  child: child ?? const SizedBox.shrink(),
                );

                return Config.enableDevicePreview
                    ? DevicePreview.appBuilder(context, widget)
                    : widget;
              },
              routerDelegate: appRouter.delegate(
                deepLinkBuilder: (deepLink) {
                  return DeepLink(_mapRouteToPageRouteInfo());
                },
                navigatorObservers: () => [AppNavigatorObserver()],
              ),
              routeInformationParser: appRouter.defaultRouteParser(),
              title: Constant.materialAppTitle,
              color: Constant.taskMenuMaterialAppColor,
              themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
              theme: lightTheme,
              darkTheme: darkTheme,
              debugShowCheckedModeBanner: kDebugMode,
              localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) =>
                  supportedLocales.map((e) => e.languageCode).contains(locale?.languageCode)
                      ? locale
                      : Locale(LanguageCode.defaultValue.localeCode),
              locale: Config.enableDevicePreview
                  ? DevicePreview.locale(context)
                  : Locale(languageCode.localeCode),
              supportedLocales: AppString.supportedLocales,
              localizationsDelegates: const [
                AppString.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          );
        },
      ),
    );
  }

  List<PageRouteInfo> _mapRouteToPageRouteInfo() {
    return [const SplashRoute()];
  }
}
