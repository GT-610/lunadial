import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type:lint

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh', 'CN')
  ];

  String get appTitle;

  String get settings;

  String get appearance;

  String get appearanceDescription;

  String get themeColor;

  String get themeColorDescription;

  String get themeMode;

  String get themeModeDescription;

  String get screen;

  String get screenDescription;

  String get keepScreenOn;

  String get keepScreenOnDescription;

  String get clockStyle;

  String get clockStyleDescription;

  String get digitalClock;

  String get digitalClockDescription;

  String get information;

  String get informationDescription;

  String get version;

  String get versionDescription;

  String get license;

  String get licenseDescription;

  String get contributors;

  String get contributorsDescription;

  String get system;

  String get light;

  String get dark;

  String get selectThemeColor;

  String get close;

  String get language;

  String get languageDescription;

  String get english;

  String get chinese;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".'
  );
}
