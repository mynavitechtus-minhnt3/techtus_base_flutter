import 'package:auto_route/auto_route.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';
// ignore: depend_on_referenced_packages
import 'package:octo_image/octo_image.dart';

import 'index.dart';

class TestUtil {
  const TestUtil._();

  static ProviderContainer createContainer({
    ProviderContainer? parent,
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) {
    final container = ProviderContainer(
      parent: parent,
      overrides: overrides,
      observers: observers,
    );

    addTearDown(container.dispose);

    return container;
  }

  static Widget buildRouterMaterialApp({
    required PageRouteInfo<dynamic> initialRoute,
    required AppRouter appRouter,
    bool isDarkMode = false,
    Locale locale = TestConfig.defaultLocale,
  }) {
    AppThemes.currentAppThemeType = isDarkMode ? AppThemeType.dark : AppThemeType.light;

    return MediaQuery(
      data: const MediaQueryData(
        size: Size(Constant.designDeviceWidth, Constant.designDeviceHeight),
      ),
      child: Builder(
        builder: (context) {
          AppDimen.current = AppDimen.init();
          AppColors.current = AppColors.of(context);

          return MaterialApp.router(
            builder: (context, child) {
              final widget = MediaQuery.withNoTextScaling(
                child: child ?? const SizedBox.shrink(),
              );

              return widget;
            },
            routerDelegate: appRouter.delegate(
              deepLinkBuilder: (deepLink) {
                return DeepLink([initialRoute]);
              },
            ),
            routeInformationParser: appRouter.defaultRouteParser(),
            title: Constant.materialAppTitle,
            color: Constant.taskMenuMaterialAppColor,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: lightTheme,
            darkTheme: darkTheme,
            debugShowCheckedModeBanner: false,
            localeResolutionCallback: (Locale? l, Iterable<Locale> supportedLocales) =>
                supportedLocales.contains(l) ? l : locale,
            locale: locale,
            supportedLocales: AppString.supportedLocales,
            localizationsDelegates: [
              if (TestConfig.additionalLocalizationsDelegate != null)
                ...TestConfig.additionalLocalizationsDelegate!,
              AppString.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }

  // ignore: prefer_named_parameters
  static Widget buildMaterialApp(
    Widget wrapper, {
    required bool isTextScaling,
    bool isDarkMode = false,
    Locale locale = TestConfig.defaultLocale,
  }) {
    AppThemes.currentAppThemeType = isDarkMode ? AppThemeType.dark : AppThemeType.light;

    return materialAppWrapper(
      platform: TestConfig.targetPlatform,
      localizations: [
        if (TestConfig.additionalLocalizationsDelegate != null)
          ...TestConfig.additionalLocalizationsDelegate!,
        AppString.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeOverrides: [locale],
      theme: isDarkMode ? darkTheme : lightTheme,
    ).call(
      MediaQuery.withClampedTextScaling(
        minScaleFactor: isTextScaling ? Constant.appMinTextScaleFactor : 1,
        maxScaleFactor: isTextScaling ? Constant.appMaxTextScaleFactor : 1,
        child: Builder(
          builder: (context) {
            AppDimen.current = AppDimen.init();
            AppColors.current = AppColors.of(context);

            return wrapper;
          },
        ),
      ),
    );
  }
}

extension CommonStateExt<T extends BaseState> on CommonState<T> {
  List<CommonState<T>> get showAndHideLoading {
    return [
      copyWith(isLoading: true, isFirstLoading: true),
      copyWith(isLoading: false, isFirstLoading: false),
    ];
  }
}

extension WidgetTesterExt on WidgetTester {
  Future<void> testWidget({
    required String filename,
    required Widget widget,
    Future<void> Function(WidgetTester, Key?)? onCreate,
    List<Override> overrides = const [],
    bool hasNetworkImage = false,
    DateTime? mockToday,
    List<TestDevice> additionalDevices = const [],
    Future<void> Function(WidgetTester)? customPump,
    bool mergeToSingleFile = true,
    bool useMultiScreenGolden = false,
    List<AppTestDeviceType> fullHeightDeviceCases = const [],
    bool includeTextScalingCase = true,
    bool isDarkMode = false,
    Locale locale = TestConfig.defaultLocale,
  }) async {
    await withClock(Clock.fixed(mockToday ?? clock.now()), () async {
      if (mergeToSingleFile) {
        for (final isTextScaling in [false, if (includeTextScalingCase) true]) {
          await _pumpDeviceBuilder(
            widget: widget,
            isTextScaling: isTextScaling,
            isDarkMode: isDarkMode,
            locale: locale,
            overrides: overrides,
            additionalDevices: additionalDevices,
            onCreate: onCreate,
            customPump: customPump,
            hasNetworkImage: hasNetworkImage,
            autoHeight: false,
            useMultiScreenGolden: useMultiScreenGolden,
            filename: '$filename/${isTextScaling ? 'text_scaling' : 'normal'}',
          );
        }
      } else {
        await Future.forEach(
            TestConfig.targetGoldenTestDevices(additionalDevices: additionalDevices),
            (device) async {
          when(() => deviceHelper.deviceType).thenReturn(
            device.type.deviceType,
          );
          for (final isTextScaling in [false, if (includeTextScalingCase) true]) {
            await _pumpWidgetBuilder(
              filename: isTextScaling
                  ? '$filename/text_scaling/${device.device.name}_${device.device.size}'
                  : '$filename/${device.device.name}_${device.device.size}',
              widget: widget,
              device: device.device,
              isTextScaling: isTextScaling,
              onCreate: onCreate,
              overrides: overrides,
              customPump: customPump,
              hasNetworkImage: hasNetworkImage,
              autoHeight: false,
              useMultiScreenGolden: useMultiScreenGolden,
              additionalDevices: additionalDevices,
              isDarkMode: isDarkMode,
              locale: locale,
            );
          }
        });
      }
    });

    if (fullHeightDeviceCases.isNotEmpty)
      await Future.forEach(
          TestConfig.targetGoldenTestDevices(
              additionalDevices: additionalDevices,
              appDevices: fullHeightDeviceCases), (device) async {
        await _pumpWidgetBuilder(
          filename: '$filename/full_height/${device.device.name}_${device.device.size}',
          widget: widget,
          device: device.device,
          onCreate: onCreate,
          overrides: overrides,
          customPump: customPump,
          isTextScaling: true,
          autoHeight: true,
          hasNetworkImage: hasNetworkImage,
          useMultiScreenGolden: useMultiScreenGolden,
          additionalDevices: additionalDevices,
          isDarkMode: isDarkMode,
          locale: locale,
        );
      });
  }

  Future<void> _pumpWidgetBuilder({
    required String filename,
    required Widget widget,
    required Device device,
    required bool isTextScaling,
    required Future<void> Function(WidgetTester, Key?)? onCreate,
    required List<Override> overrides,
    required Future<void> Function(WidgetTester)? customPump,
    required bool hasNetworkImage,
    required bool autoHeight,
    required bool useMultiScreenGolden,
    required bool isDarkMode,
    required Locale locale,
    required List<TestDevice> additionalDevices,
  }) async {
    final fullOverrides = [
      ...TestConfig.baseOverrides(),
      ...overrides,
    ];
    await runAsync(() async {
      await pumpWidgetBuilder(
        widget,
        wrapper: (wrapper) => ProviderScope(
          overrides: fullOverrides,
          child: TestUtil.buildMaterialApp(
            wrapper,
            isTextScaling: isTextScaling,
            isDarkMode: isDarkMode,
            locale: locale,
          ),
        ),
        surfaceSize: device.size,
        textScaleSize: isTextScaling ? 2 : 1,
      );
      if (hasNetworkImage) {
        for (final element in find.byType(OctoImage).evaluate()) {
          final widget = element.widget.safeCast<OctoImage>();
          // ignore: avoid_nested_conditions
          if (widget != null) {
            final image = widget.image;
            await precacheImage(image, element);
          }
        }
        await pumpAndSettle();
      }
    });

    await onCreate?.call(this, null);

    await _takeScreenshot(
      filename: filename,
      customPump: customPump,
      autoHeight: autoHeight,
      useMultiScreenGolden: useMultiScreenGolden,
      additionalDevices: additionalDevices,
      isTextScaling: isTextScaling,
    );
  }

  Future<void> _pumpDeviceBuilder({
    required String filename,
    required Widget widget,
    required bool isTextScaling,
    required Future<void> Function(WidgetTester, Key?)? onCreate,
    required List<Override> overrides,
    required Future<void> Function(WidgetTester)? customPump,
    required bool hasNetworkImage,
    required bool autoHeight,
    required bool useMultiScreenGolden,
    required bool isDarkMode,
    required Locale locale,
    required List<TestDevice> additionalDevices,
  }) async {
    final fullOverrides = [
      ...TestConfig.baseOverrides(),
      ...overrides,
    ];
    await runAsync(() async {
      await pumpDeviceBuilder(
        DeviceBuilder()
          ..overrideDevicesForAllScenarios(
            devices: TestConfig.targetGoldenTestDevices(
              additionalDevices: additionalDevices,
              isTextScaling: isTextScaling,
            ).map((e) => e.device).toList(),
          )
          ..addScenario(
              widget: widget,
              onCreate: (key) async {
                if (onCreate != null) {
                  await onCreate(this, key);
                }
              }),
        wrapper: (wrapper) => ProviderScope(
          overrides: fullOverrides,
          child: TestUtil.buildMaterialApp(
            wrapper,
            isTextScaling: isTextScaling,
            isDarkMode: isDarkMode,
            locale: locale,
          ),
        ),
      );
      if (hasNetworkImage) {
        for (final element in find.byType(OctoImage).evaluate()) {
          final widget = element.widget.safeCast<OctoImage>();
          // ignore: avoid_nested_conditions
          if (widget != null) {
            final image = widget.image;
            await precacheImage(image, element);
          }
        }
        await pumpAndSettle();
      }
    });

    // await onCreate?.call(this, null);

    await _takeScreenshot(
      filename: filename,
      customPump: customPump,
      autoHeight: autoHeight,
      useMultiScreenGolden: useMultiScreenGolden,
      additionalDevices: additionalDevices,
      isTextScaling: isTextScaling,
    );
  }

  Future<void> _takeScreenshot({
    required String filename,
    required Future<void> Function(WidgetTester)? customPump,
    required bool autoHeight,
    required bool useMultiScreenGolden,
    required List<TestDevice> additionalDevices,
    required bool isTextScaling,
  }) async {
    if (useMultiScreenGolden) {
      return multiScreenGolden(
        this,
        filename,
        customPump: customPump,
        autoHeight: autoHeight,
        devices: TestConfig.targetGoldenTestDevices(
          additionalDevices: additionalDevices,
          isTextScaling: isTextScaling,
        ).map((e) => e.device).toList(),
      );
    }

    await screenMatchesGolden(
      this,
      filename,
      customPump: customPump,
      autoHeight: autoHeight,
    );
  }

  Future<void> tapOnBottomNavigationTab(int index) async {
    final bottomNavigatorBarFinder = find.byType(BottomNavigationBar);
    expect(bottomNavigatorBarFinder, findsOneWidget);
    final bottomBarWidget = widget<BottomNavigationBar>(bottomNavigatorBarFinder);
    expect(bottomBarWidget.onTap, isNotNull);
    bottomBarWidget.onTap!.call(index);
    await pumpAndSettle();
  }

  Future<void> safelyTap(Finder finder) async {
    await ensureVisible(finder);
    await pumpAndSettle();
    await tap(finder, warnIfMissed: false);
    await pumpAndSettle();
  }
}

extension FinderExt on Finder {
  // ignore: prefer_named_parameters
  Finder isDescendantOf(Finder finder) {
    return find.descendant(of: finder, matching: this);
  }

  // ignore: prefer_named_parameters
  Finder isAncestorOf(Finder finder) {
    return find.ancestor(of: finder, matching: this);
  }

  // ignore: prefer_named_parameters
  Finder isDescendantOfKeyIfAny(Key? key) {
    return key != null ? isDescendantOf(find.byKey(key)) : this;
  }
}
