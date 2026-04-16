import 'package:flutter/material.dart';

enum AppLocaleOption {
  system,
  en,
  zhCn;

  Locale? get locale {
    switch (this) {
      case AppLocaleOption.system:
        return null;
      case AppLocaleOption.en:
        return const Locale('en');
      case AppLocaleOption.zhCn:
        return const Locale('zh', 'CN');
    }
  }

  String get storageValue {
    switch (this) {
      case AppLocaleOption.system:
        return 'system';
      case AppLocaleOption.en:
        return 'en';
      case AppLocaleOption.zhCn:
        return 'zh_CN';
    }
  }

  static AppLocaleOption fromStorageValue(Object? value) {
    switch (value) {
      case 'en':
        return AppLocaleOption.en;
      case 'zh_CN':
        return AppLocaleOption.zhCn;
      default:
        return AppLocaleOption.system;
    }
  }
}
