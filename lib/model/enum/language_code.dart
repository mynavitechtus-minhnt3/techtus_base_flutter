import 'dart:ui';

import 'package:dartx/dartx.dart';

import '../../index.dart';

enum LanguageCode {
  en(
    localeCode: 'en',
    value: Constant.en,
  ),
  ja(
    localeCode: 'ja',
    value: Constant.ja,
  );

  Locale get locale => Locale(localeCode);

  const LanguageCode({
    required this.localeCode,
    required this.value,
  });

  factory LanguageCode.fromValue(String? data) {
    return values.firstOrNullWhere((element) => element.value == data) ?? defaultValue;
  }

  final String localeCode;
  final String value;

  static const defaultValue = ja;
}
