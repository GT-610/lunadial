import 'package:fl_lib/fl_lib.dart' as fl;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/night_mode_behavior.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';
import 'package:lunadial/features/settings/presentation/widgets/settings_save_error_banner.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _appVersion;

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
    final translations = AppLocalizations.of(context)!;

    final settingsSections = <Widget>[
      _SettingsSection(
        title: translations.appearance,
        children: const [
          _ThemeColorTile(),
          _ThemeModeTile(),
          _LocaleTile(),
        ],
      ),
      _SettingsSection(
        title: translations.screen,
        children: const [
          _KeepScreenOnTile(),
        ],
      ),
      _SettingsSection(
        title: translations.nightAndBurnIn,
        children: const [
          _NightModeBehaviorTile(),
          _NightModeStartTimeTile(),
          _NightModeEndTimeTile(),
          _BurnInProtectionTile(),
        ],
      ),
      _SettingsSection(
        title: translations.clockStyle,
        children: const [
          _ClockDisplayModeTile(),
        ],
      ),
      _SettingsSection(
        title: translations.timeDisplay,
        children: const [
          _TimeFormatTile(),
          _ShowSecondsTile(),
          _DigitalClockLeadingZeroTile(),
        ],
      ),
      _SettingsSection(
        title: translations.information,
        children: [
          _ActionTile(
            title: translations.version,
            subtitle: translations.versionDescription,
            trailing: Text(
              _appVersion ?? translations.loading,
              style: fl.UIs.textGrey,
            ),
          ),
          _ActionTile(
            title: translations.license,
            subtitle: translations.licenseDescription,
            trailing: _buildChevronValue(null),
            onTap: () => showLicensePage(context: context),
          ),
          _ActionTile(
            title: translations.contributors,
            subtitle: translations.contributorsDescription,
            trailing: _buildChevronValue(null),
            onTap: () => _showInfoDialog(
              context,
              title: translations.contributors,
              content: translations.contributorsDialogContent,
            ),
          ),
          _ActionTile(
            title: translations.appTitle,
            subtitle: translations.informationDescription,
            trailing: _buildChevronValue(null),
            onTap: () => _showInfoDialog(
              context,
              title: translations.appTitle,
              content: translations.appDescription,
            ),
          ),
        ],
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
                Selector<AppSettingsController, bool>(
                  selector: (_, controller) => controller.hasSaveError,
                  builder: (context, hasSaveError, _) {
                    if (!hasSaveError) {
                      return const SizedBox.shrink();
                    }
                    final controller = context.read<AppSettingsController>();
                    return Column(
                      children: [
                        SettingsSaveErrorBanner(
                          error: controller.saveError,
                          onRetry: controller.retrySave,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                if (columns == 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _intersperse(
                      settingsSections,
                      const SizedBox(height: gap),
                    ),
                  )
                else
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: settingsSections
                        .map(
                          (section) => SizedBox(
                            width: sectionWidth,
                            child: section,
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fl.CenterGreyTitle(title),
        Column(children: children),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return fl.CardX(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: fl.UIs.textGrey),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return fl.CardX(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: fl.UIs.textGrey),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ThemeColorTile extends StatelessWidget {
  const _ThemeColorTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, Color>(
      selector: (_, controller) => controller.settings.themeColor,
      builder: (context, themeColor, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.themeColor,
          subtitle: translations.themeColorDescription,
          trailing: _buildValueRow(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: themeColor,
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
          onTap: () => _showThemeColorDialog(context, controller),
        );
      },
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, ThemeMode>(
      selector: (_, controller) => controller.settings.themeMode,
      builder: (context, themeMode, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.themeMode,
          subtitle: translations.themeModeDescription,
          trailing: _buildChevronValue(
            _themeModeLabel(themeMode, translations),
          ),
          onTap: () => _showThemeModeDialog(context, controller),
        );
      },
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, AppLocaleOption>(
      selector: (_, controller) => controller.settings.localeOption,
      builder: (context, localeOption, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.language,
          subtitle: translations.languageDescription,
          trailing: _buildChevronValue(
            _localeLabel(localeOption, translations),
          ),
          onTap: () => _showLanguageDialog(context, controller),
        );
      },
    );
  }
}

class _KeepScreenOnTile extends StatelessWidget {
  const _KeepScreenOnTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, bool>(
      selector: (_, controller) => controller.settings.keepScreenOn,
      builder: (context, keepScreenOn, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _SwitchTile(
          title: translations.keepScreenOn,
          subtitle: translations.keepScreenOnDescription,
          value: keepScreenOn,
          onChanged: controller.setKeepScreenOn,
        );
      },
    );
  }
}

class _NightModeBehaviorTile extends StatelessWidget {
  const _NightModeBehaviorTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, NightModeBehavior>(
      selector: (_, controller) => controller.settings.nightModeBehavior,
      builder: (context, behavior, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.nightDisplayMode,
          subtitle: translations.nightDisplayModeDescription,
          trailing: _buildChevronValue(
            _nightModeBehaviorLabel(behavior, translations),
          ),
          onTap: () => _showNightModeBehaviorDialog(context, controller),
        );
      },
    );
  }
}

class _NightModeStartTimeTile extends StatelessWidget {
  const _NightModeStartTimeTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, NightModeBehavior>(
      selector: (_, controller) => controller.settings.nightModeBehavior,
      builder: (context, behavior, _) {
        if (behavior != NightModeBehavior.scheduled) {
          return const SizedBox.shrink();
        }
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.nightModeStartTime,
          subtitle: translations.nightModeStartTimeDescription,
          trailing: _buildChevronValue(
            _timeOfDayLabel(context, controller.settings.nightModeStartTime),
          ),
          onTap: () => _pickNightModeTime(
            context,
            title: translations.nightModeStartTime,
            initialTime: controller.settings.nightModeStartTime,
            onSelected: controller.setNightModeStartTime,
          ),
        );
      },
    );
  }
}

class _NightModeEndTimeTile extends StatelessWidget {
  const _NightModeEndTimeTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, NightModeBehavior>(
      selector: (_, controller) => controller.settings.nightModeBehavior,
      builder: (context, behavior, _) {
        if (behavior != NightModeBehavior.scheduled) {
          return const SizedBox.shrink();
        }
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.nightModeEndTime,
          subtitle: translations.nightModeEndTimeDescription,
          trailing: _buildChevronValue(
            _timeOfDayLabel(context, controller.settings.nightModeEndTime),
          ),
          onTap: () => _pickNightModeTime(
            context,
            title: translations.nightModeEndTime,
            initialTime: controller.settings.nightModeEndTime,
            onSelected: controller.setNightModeEndTime,
          ),
        );
      },
    );
  }
}

class _BurnInProtectionTile extends StatelessWidget {
  const _BurnInProtectionTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, bool>(
      selector: (_, controller) => controller.settings.burnInProtectionEnabled,
      builder: (context, enabled, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _SwitchTile(
          title: translations.burnInProtection,
          subtitle: translations.burnInProtectionDescription,
          value: enabled,
          onChanged: controller.setBurnInProtectionEnabled,
        );
      },
    );
  }
}

class _ClockDisplayModeTile extends StatelessWidget {
  const _ClockDisplayModeTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, ClockDisplayMode>(
      selector: (_, controller) => controller.settings.clockDisplayMode,
      builder: (context, mode, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.clockDisplayMode,
          subtitle: translations.clockDisplayModeDescription,
          trailing: _buildChevronValue(
            _clockModeLabel(mode, translations),
          ),
          onTap: () => _showClockModeDialog(context, controller),
        );
      },
    );
  }
}

class _TimeFormatTile extends StatelessWidget {
  const _TimeFormatTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, TimeFormatPreference>(
      selector: (_, controller) => controller.settings.timeFormatPreference,
      builder: (context, preference, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _ActionTile(
          title: translations.timeFormat,
          subtitle: translations.timeFormatDescription,
          trailing: _buildChevronValue(
            _timeFormatLabel(preference, translations),
          ),
          onTap: () => _showTimeFormatDialog(context, controller),
        );
      },
    );
  }
}

class _ShowSecondsTile extends StatelessWidget {
  const _ShowSecondsTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, bool>(
      selector: (_, controller) => controller.settings.showSeconds,
      builder: (context, showSeconds, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _SwitchTile(
          title: translations.showSeconds,
          subtitle: translations.showSecondsDescription,
          value: showSeconds,
          onChanged: controller.setShowSeconds,
        );
      },
    );
  }
}

class _DigitalClockLeadingZeroTile extends StatelessWidget {
  const _DigitalClockLeadingZeroTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, bool>(
      selector: (_, controller) => controller.settings.digitalClockLeadingZero,
      builder: (context, leadingZero, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _SwitchTile(
          title: translations.digitalClockLeadingZero,
          subtitle: translations.digitalClockLeadingZeroDescription,
          value: leadingZero,
          onChanged: controller.setDigitalClockLeadingZero,
        );
      },
    );
  }
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

List<Widget> _intersperse(List<Widget> items, Widget separator) {
  if (items.isEmpty) return const [];
  final result = <Widget>[items.first];
  for (var i = 1; i < items.length; i++) {
    result.add(separator);
    result.add(items[i]);
  }
  return result;
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

Future<void> _showTimeFormatDialog(
  BuildContext context,
  AppSettingsController settingsController,
) async {
  final translations = AppLocalizations.of(context)!;
  final currentValue = settingsController.settings.timeFormatPreference;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(translations.timeFormat),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TimeFormatPreference.values
            .map((preference) {
              return ListTile(
                title: Text(_timeFormatLabel(preference, translations)),
                trailing: preference == currentValue
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await settingsController.setTimeFormatPreference(
                    preference,
                  );
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

Future<void> _showNightModeBehaviorDialog(
  BuildContext context,
  AppSettingsController settingsController,
) async {
  final translations = AppLocalizations.of(context)!;
  final currentValue = settingsController.settings.nightModeBehavior;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(translations.nightDisplayMode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: NightModeBehavior.values
            .map((behavior) {
              return ListTile(
                title: Text(_nightModeBehaviorLabel(behavior, translations)),
                subtitle: Text(
                  _nightModeBehaviorDescription(behavior, translations),
                  style: fl.UIs.textGrey,
                ),
                trailing: behavior == currentValue
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await settingsController.setNightModeBehavior(behavior);
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

Future<void> _pickNightModeTime(
  BuildContext context, {
  required String title,
  required TimeOfDay initialTime,
  required Future<void> Function(TimeOfDay) onSelected,
}) async {
  final selected = await showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: title,
  );
  if (selected == null) {
    return;
  }

  await onSelected(selected);
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
      return translations.analogClock;
  }
}

String _timeFormatLabel(
  TimeFormatPreference preference,
  AppLocalizations translations,
) {
  switch (preference) {
    case TimeFormatPreference.system:
      return translations.systemTimeFormat;
    case TimeFormatPreference.twelveHour:
      return translations.twelveHourFormat;
    case TimeFormatPreference.twentyFourHour:
      return translations.twentyFourHourFormat;
  }
}

String _nightModeBehaviorLabel(
  NightModeBehavior behavior,
  AppLocalizations translations,
) {
  switch (behavior) {
    case NightModeBehavior.off:
      return translations.nightModeOff;
    case NightModeBehavior.on:
      return translations.nightModeOn;
    case NightModeBehavior.scheduled:
      return translations.nightModeScheduled;
    case NightModeBehavior.followSystem:
      return translations.nightModeFollowSystem;
  }
}

String _nightModeBehaviorDescription(
  NightModeBehavior behavior,
  AppLocalizations translations,
) {
  switch (behavior) {
    case NightModeBehavior.off:
      return translations.nightModeOffDescription;
    case NightModeBehavior.on:
      return translations.nightModeOnDescription;
    case NightModeBehavior.scheduled:
      return translations.nightModeScheduledDescription;
    case NightModeBehavior.followSystem:
      return translations.nightModeFollowSystemDescription;
  }
}

String _timeOfDayLabel(BuildContext context, TimeOfDay time) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    time,
    alwaysUse24HourFormat:
        MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ?? false,
  );
}
