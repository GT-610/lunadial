import 'package:fl_lib/fl_lib.dart' as fl;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/presentation/widgets/settings_save_error_banner.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = 'Loading...';

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

    final buildSuffix = packageInfo.buildNumber.isEmpty
        ? ''
        : '+${packageInfo.buildNumber}';

    setState(() {
      _appVersion = '${packageInfo.version}$buildSuffix';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<AppSettingsController>();
    final settings = settingsController.settings;
    final translations = AppLocalizations.of(context)!;

    final sections = <_SettingsSection>[
      _SettingsSection(
        title: translations.appearance,
        child: _buildSettingsGroup([
          _buildActionTile(
            title: translations.themeColor,
            subtitle: translations.themeColorDescription,
            trailing: _buildValueRow(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: settings.themeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showThemeColorDialog(context, settingsController),
          ),
          _buildActionTile(
            title: translations.themeMode,
            subtitle: translations.themeModeDescription,
            trailing: _buildChevronValue(
              _themeModeLabel(settings.themeMode, translations),
            ),
            onTap: () => _showThemeModeDialog(context, settingsController),
          ),
          _buildActionTile(
            title: translations.language,
            subtitle: translations.languageDescription,
            trailing: _buildChevronValue(
              _localeLabel(settings.localeOption, translations),
            ),
            onTap: () => _showLanguageDialog(context, settingsController),
          ),
        ]),
      ),
      _SettingsSection(
        title: translations.screen,
        child: _buildSettingsGroup([
          _buildSwitchTile(
            title: translations.keepScreenOn,
            subtitle: translations.keepScreenOnDescription,
            value: settings.keepScreenOn,
            onChanged: settingsController.setKeepScreenOn,
          ),
        ]),
      ),
      _SettingsSection(
        title: translations.clockStyle,
        child: _buildSettingsGroup([
          _buildActionTile(
            title: translations.digitalClock,
            subtitle: translations.digitalClockDescription,
            trailing: _buildChevronValue(
              _clockModeLabel(settings.clockDisplayMode, translations),
            ),
            onTap: () => _showClockModeDialog(context, settingsController),
          ),
        ]),
      ),
      _SettingsSection(
        title: translations.information,
        child: _buildSettingsGroup([
          _buildActionTile(
            title: translations.version,
            subtitle: translations.versionDescription,
            trailing: Text(_appVersion, style: fl.UIs.textGrey),
          ),
          _buildActionTile(
            title: translations.license,
            subtitle: translations.licenseDescription,
            trailing: _buildChevronValue(null),
            onTap: () => showLicensePage(context: context),
          ),
          _buildActionTile(
            title: translations.contributors,
            subtitle: translations.contributorsDescription,
            trailing: _buildChevronValue(null),
            onTap: () => _showInfoDialog(
              context,
              title: translations.contributors,
              content:
                  'LunaDial is being organized for long-term development.\n\n'
                  'Contributor credits will continue to be expanded as the project evolves. '
                  'Please refer to the repository history and merged pull requests for the latest record.',
            ),
          ),
          _buildActionTile(
            title: translations.appTitle,
            subtitle: translations.informationDescription,
            trailing: _buildChevronValue(null),
            onTap: () => _showInfoDialog(
              context,
              title: translations.appTitle,
              content:
                  'LunaDial is a cross-platform clock app focused on turning spare screens into elegant full-time clocks.\n\n'
                  'This stage emphasizes structure, reuse, and a clean base for future features.',
            ),
          ),
        ]),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(translations.settings)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1080 ? 2 : 1;
          const gap = 16.0;
          final usableWidth = constraints.maxWidth - 32;
          final sectionWidth = columns == 1
              ? usableWidth
              : (usableWidth - gap) / 2;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (settingsController.hasSaveError) ...[
                  SettingsSaveErrorBanner(
                    error: settingsController.saveError,
                    onRetry: settingsController.retrySave,
                  ),
                  const SizedBox(height: 16),
                ],
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: sections
                      .map((section) {
                        return SizedBox(
                          width: sectionWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              fl.CenterGreyTitle(section.title),
                              section.child,
                            ],
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Column(children: children);
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return fl.CardX(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: fl.UIs.textGrey),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return fl.CardX(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: fl.UIs.textGrey),
        trailing: Switch.adaptive(
          value: value,
          onChanged: (next) {
            onChanged(next);
          },
        ),
      ),
    );
  }

  Widget _buildChevronValue(String? value) {
    return _buildValueRow(
      children: [
        if (value != null) ...[Text(value), const SizedBox(width: 8)],
        const Icon(Icons.chevron_right),
      ],
    );
  }

  Widget _buildValueRow({required List<Widget> children}) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Future<void> _showThemeColorDialog(
    BuildContext context,
    AppSettingsController settingsController,
  ) async {
    final translations = AppLocalizations.of(context)!;
    var draftColor = settingsController.settings.themeColor;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(translations.selectThemeColor),
            content: fl.ColorPicker(
              color: draftColor,
              onColorChanged: (color) {
                setState(() {
                  draftColor = color;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await settingsController.setThemeColor(draftColor);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showThemeModeDialog(
    BuildContext context,
    AppSettingsController settingsController,
  ) async {
    final translations = AppLocalizations.of(context)!;
    final currentValue = settingsController.settings.themeMode;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(translations.themeMode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values
              .map((mode) {
                return ListTile(
                  title: Text(_themeModeLabel(mode, translations)),
                  trailing: mode == currentValue
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () async {
                    await settingsController.setThemeMode(mode);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    AppSettingsController settingsController,
  ) async {
    final translations = AppLocalizations.of(context)!;
    final currentValue = settingsController.settings.localeOption;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(translations.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLocaleOption.values
              .map((option) {
                return ListTile(
                  title: Text(_localeLabel(option, translations)),
                  trailing: option == currentValue
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () async {
                    await settingsController.setLocaleOption(option);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _showClockModeDialog(
    BuildContext context,
    AppSettingsController settingsController,
  ) async {
    final translations = AppLocalizations.of(context)!;
    final currentValue = settingsController.settings.clockDisplayMode;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(translations.clockStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ClockDisplayMode.values
              .map((mode) {
                return ListTile(
                  title: Text(_clockModeLabel(mode, translations)),
                  trailing: mode == currentValue
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () async {
                    await settingsController.setClockDisplayMode(mode);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                );
              })
              .toList(growable: false),
        ),
      ),
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

  String _themeModeLabel(ThemeMode mode, AppLocalizations translations) {
    switch (mode) {
      case ThemeMode.system:
        return translations.system;
      case ThemeMode.light:
        return translations.light;
      case ThemeMode.dark:
        return translations.dark;
    }
  }

  String _localeLabel(AppLocaleOption option, AppLocalizations translations) {
    switch (option) {
      case AppLocaleOption.system:
        return translations.system;
      case AppLocaleOption.en:
        return translations.english;
      case AppLocaleOption.zhCn:
        return translations.chinese;
    }
  }

  String _clockModeLabel(ClockDisplayMode mode, AppLocalizations translations) {
    switch (mode) {
      case ClockDisplayMode.digital:
        return translations.digitalClock;
      case ClockDisplayMode.analog:
        return translations.localeName.startsWith('zh')
            ? '模拟时钟'
            : 'Analog Clock';
    }
  }
}

class _SettingsSection {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;
}
