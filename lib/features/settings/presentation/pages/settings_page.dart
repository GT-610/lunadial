import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/presentation/widgets/settings_item.dart';
import 'package:lunadial/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = 'Loading...';

  static const List<Color> _colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }

    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<AppSettingsController>();
    final settings = settingsController.settings;
    final translations = AppLocalizations.of(context)!;
    final isBlackTheme = settings.themeColor == Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(translations.settings),
        backgroundColor: isBlackTheme ? Colors.grey.shade900 : null,
      ),
      backgroundColor: isBlackTheme ? Colors.black : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionCard(
            title: translations.appearance,
            subtitle: translations.appearanceDescription,
            children: [
              SettingsItem(
                title: translations.themeColor,
                description: translations.themeColorDescription,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: settings.themeColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                ),
                onTap: () => _showThemeColorDialog(context, settingsController),
              ),
              const SizedBox(height: 8),
              SettingsItem(
                title: translations.themeMode,
                description: translations.themeModeDescription,
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(translations.system),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(translations.light),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(translations.dark),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settingsController.setThemeMode(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              SettingsItem(
                title: translations.language,
                description: translations.languageDescription,
                trailing: DropdownButton<AppLocaleOption>(
                  value: settings.localeOption,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: AppLocaleOption.system,
                      child: Text(translations.system),
                    ),
                    DropdownMenuItem(
                      value: AppLocaleOption.en,
                      child: Text(translations.english),
                    ),
                    DropdownMenuItem(
                      value: AppLocaleOption.zhCn,
                      child: Text(translations.chinese),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settingsController.setLocaleOption(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: translations.screen,
            subtitle: translations.screenDescription,
            children: [
              SettingsItem(
                title: translations.keepScreenOn,
                description: translations.keepScreenOnDescription,
                trailing: Switch(
                  value: settings.keepScreenOn,
                  onChanged: settingsController.setKeepScreenOn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: translations.clockStyle,
            subtitle: translations.clockStyleDescription,
            children: [
              SettingsItem(
                title: translations.digitalClock,
                description: translations.digitalClockDescription,
                trailing: Switch(
                  value: settings.clockDisplayMode == ClockDisplayMode.digital,
                  onChanged: (value) {
                    settingsController.setClockDisplayMode(
                      value
                          ? ClockDisplayMode.digital
                          : ClockDisplayMode.analog,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: translations.information,
            subtitle: translations.informationDescription,
            children: [
              SettingsItem(
                title: translations.version,
                description: translations.versionDescription,
                trailing: Text(
                  _appVersion,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SettingsItem(
                title: translations.license,
                description: translations.licenseDescription,
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () {
                  _showInfoDialog(
                    context,
                    title: translations.license,
                    content:
                        'GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007\n\n'
                        'This program is free software: you can redistribute it and/or modify\n'
                        'it under the terms of the GNU General Public License as published by\n'
                        'the Free Software Foundation, either version 3 of the License, or\n'
                        '(at your option) any later version.\n\n'
                        'This program is distributed in the hope that it will be useful,\n'
                        'but WITHOUT ANY WARRANTY; without even the implied warranty of\n'
                        'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n'
                        'GNU General Public License for more details.\n\n'
                        'You should have received a copy of the GNU General Public License\n'
                        'along with this program. If not, see <https://www.gnu.org/licenses/>.',
                  );
                },
              ),
              const SizedBox(height: 8),
              SettingsItem(
                title: translations.contributors,
                description: translations.contributorsDescription,
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () {
                  _showInfoDialog(
                    context,
                    title: translations.contributors,
                    content:
                        'Contributors list placeholder\n\nMore contributors will be added here.',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showThemeColorDialog(
    BuildContext context,
    AppSettingsController settingsController,
  ) async {
    final translations = AppLocalizations.of(context)!;
    final selected = settingsController.settings.themeColor;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(translations.selectThemeColor),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.map((color) {
                final isSelected = color == selected;
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    settingsController.setThemeColor(color);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final translations = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(translations.close),
          ),
        ],
      ),
    );
  }
}
