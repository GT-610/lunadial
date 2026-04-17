import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/settings/domain/app_locale_option.dart';

void main() {
  test('zhCn locale option resolves to supported zh locale', () {
    expect(AppLocaleOption.zhCn.locale, const Locale('zh'));
    expect(AppLocaleOption.zhCn.storageValue, 'zh_CN');
  });
}
