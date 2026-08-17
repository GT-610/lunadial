import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    unawaited(_loadAppVersion());
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
          _DynamicColorTile(),
          _ThemeColorTile(),
          _ThemeModeTile(),
          _LocaleTile(),
        ],
      ),
      _SettingsSection(
        title: translations.screen,
        children: const [_KeepScreenOnTile()],
      ),
      _SettingsSection(
        title: translations.nightAndBurnIn,
        children: const [
          _NightModeBehaviorTile(),
          _NightModeTimeTile.start(),
          _NightModeTimeTile.end(),
          _BurnInProtectionTile(),
        ],
      ),
      _SettingsSection(
        title: translations.clockStyle,
        children: const [_ClockDisplayModeTile()],
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _ActionTile(
            title: translations.license,
            subtitle: translations.licenseDescription,
            trailing: _buildChevronValue(null),
            onTap: () => showLicensePage(context: context),
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
                          (section) =>
                              SizedBox(width: sectionWidth, child: section),
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
        Padding(
          padding: const EdgeInsets.only(top: 23, bottom: 17),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
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
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
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
    return _ActionTile(
      title: title,
      subtitle: subtitle,
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
    );
  }
}

class _ThemeColorPicker extends StatefulWidget {
  const _ThemeColorPicker({required this.color, required this.onColorChanged});

  final Color color;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_ThemeColorPicker> createState() => _ThemeColorPickerState();
}

class _ThemeColorPickerState extends State<_ThemeColorPicker> {
  late int _red = _channel(widget.color, 16);
  late int _green = _channel(widget.color, 8);
  late int _blue = _channel(widget.color, 0);
  late final TextEditingController _hexController = TextEditingController(
    text: _hexValue(widget.color),
  );

  Color get _color => Color.fromARGB(255, _red, _green, _blue);

  @override
  void didUpdateWidget(covariant _ThemeColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color && widget.color != _color) {
      _red = _channel(widget.color, 16);
      _green = _channel(widget.color, 8);
      _blue = _channel(widget.color, 0);
      _hexController.text = _hexValue(widget.color);
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _setColor({int? red, int? green, int? blue}) {
    setState(() {
      _red = red ?? _red;
      _green = green ?? _green;
      _blue = blue ?? _blue;
      _hexController.text = _hexValue(_color);
    });
    widget.onColorChanged(_color);
  }

  void _parseHexColor(String value) {
    final normalized = value.replaceFirst('#', '');
    if (normalized.length != 6) {
      return;
    }
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) {
      return;
    }

    final color = Color(0xff000000 | parsed);
    setState(() {
      _red = _channel(color, 16);
      _green = _channel(color, 8);
      _blue = _channel(color, 0);
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: const Key('theme-color-preview'),
            height: 48,
            width: 96,
            decoration: BoxDecoration(
              color: _color,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('theme-color-hex-field'),
            controller: _hexController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
              LengthLimitingTextInputFormatter(7),
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.colorize),
              labelText: 'RGB',
              hintText: '#4CAF50',
            ),
            onChanged: _parseHexColor,
          ),
          const SizedBox(height: 8),
          _buildChannelSlider(
            label: 'R',
            value: _red,
            onChanged: (value) => _setColor(red: value),
          ),
          _buildChannelSlider(
            label: 'G',
            value: _green,
            onChanged: (value) => _setColor(green: value),
          ),
          _buildChannelSlider(
            label: 'B',
            value: _blue,
            onChanged: (value) => _setColor(blue: value),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelSlider({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            label: value.toString(),
            onChanged: (nextValue) => onChanged(nextValue.round()),
          ),
        ),
        SizedBox(width: 32, child: Text(value.toString())),
      ],
    );
  }

  static int _channel(Color color, int shift) {
    return (color.toARGB32() >> shift) & 0xff;
  }

  static String _hexValue(Color color) {
    final rgb = color.toARGB32() & 0x00ffffff;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
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

class _DynamicColorTile extends StatelessWidget {
  const _DynamicColorTile();

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, bool>(
      selector: (_, controller) => controller.settings.useDynamicColor,
      builder: (context, useDynamicColor, _) {
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        return _SwitchTile(
          title: translations.useDynamicColor,
          subtitle: translations.useDynamicColorDescription,
          value: useDynamicColor,
          onChanged: controller.setUseDynamicColor,
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

enum _NightModeTimeBoundary { start, end }

class _NightModeTimeTile extends StatelessWidget {
  const _NightModeTimeTile.start() : boundary = _NightModeTimeBoundary.start;

  const _NightModeTimeTile.end() : boundary = _NightModeTimeBoundary.end;

  final _NightModeTimeBoundary boundary;

  @override
  Widget build(BuildContext context) {
    return Selector<AppSettingsController, (NightModeBehavior, TimeOfDay)>(
      selector: (_, controller) {
        final settings = controller.settings;
        return (
          settings.nightModeBehavior,
          boundary == _NightModeTimeBoundary.start
              ? settings.nightModeStartTime
              : settings.nightModeEndTime,
        );
      },
      builder: (context, data, _) {
        final (behavior, time) = data;
        if (behavior != NightModeBehavior.scheduled) {
          return const SizedBox.shrink();
        }
        final controller = context.read<AppSettingsController>();
        final translations = AppLocalizations.of(context)!;
        final isStart = boundary == _NightModeTimeBoundary.start;
        final title = isStart
            ? translations.nightModeStartTime
            : translations.nightModeEndTime;
        return _ActionTile(
          title: title,
          subtitle: isStart
              ? translations.nightModeStartTimeDescription
              : translations.nightModeEndTimeDescription,
          trailing: _buildChevronValue(_timeOfDayLabel(context, time)),
          onTap: () => _pickNightModeTime(
            context,
            title: title,
            initialTime: time,
            onSelected: isStart
                ? controller.setNightModeStartTime
                : controller.setNightModeEndTime,
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
          trailing: _buildChevronValue(_clockModeLabel(mode, translations)),
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
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (value != null) ...[Text(value), const SizedBox(width: 8)],
      const Icon(Icons.chevron_right),
    ],
  );
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
) {
  final translations = AppLocalizations.of(context)!;
  var draftColor = settingsController.settings.themeColor;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        scrollable: true,
        title: Text(translations.selectThemeColor),
        content: _ThemeColorPicker(
          color: draftColor,
          onColorChanged: (color) {
            draftColor = color;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
      );
    },
  );
}

Future<void> _showThemeModeDialog(
  BuildContext context,
  AppSettingsController settingsController,
) {
  final translations = AppLocalizations.of(context)!;
  return _showSelectionDialog<ThemeMode>(
    context: context,
    title: translations.themeMode,
    values: ThemeMode.values,
    currentValue: settingsController.settings.themeMode,
    labelFor: (mode) => _themeModeLabel(mode, translations),
    onSelected: settingsController.setThemeMode,
  );
}

Future<void> _showLanguageDialog(
  BuildContext context,
  AppSettingsController settingsController,
) {
  final translations = AppLocalizations.of(context)!;
  return _showSelectionDialog<AppLocaleOption>(
    context: context,
    title: translations.language,
    values: AppLocaleOption.values,
    currentValue: settingsController.settings.localeOption,
    labelFor: (option) => _localeLabel(option, translations),
    onSelected: settingsController.setLocaleOption,
  );
}

Future<void> _showClockModeDialog(
  BuildContext context,
  AppSettingsController settingsController,
) {
  final translations = AppLocalizations.of(context)!;
  return _showSelectionDialog<ClockDisplayMode>(
    context: context,
    title: translations.clockStyle,
    values: ClockDisplayMode.values,
    currentValue: settingsController.settings.clockDisplayMode,
    labelFor: (mode) => _clockModeLabel(mode, translations),
    onSelected: settingsController.setClockDisplayMode,
  );
}

Future<void> _showTimeFormatDialog(
  BuildContext context,
  AppSettingsController settingsController,
) {
  final translations = AppLocalizations.of(context)!;
  return _showSelectionDialog<TimeFormatPreference>(
    context: context,
    title: translations.timeFormat,
    values: TimeFormatPreference.values,
    currentValue: settingsController.settings.timeFormatPreference,
    labelFor: (preference) => _timeFormatLabel(preference, translations),
    onSelected: settingsController.setTimeFormatPreference,
  );
}

Future<void> _showNightModeBehaviorDialog(
  BuildContext context,
  AppSettingsController settingsController,
) {
  final translations = AppLocalizations.of(context)!;
  return _showSelectionDialog<NightModeBehavior>(
    context: context,
    title: translations.nightDisplayMode,
    values: NightModeBehavior.values,
    currentValue: settingsController.settings.nightModeBehavior,
    labelFor: (behavior) => _nightModeBehaviorLabel(behavior, translations),
    descriptionFor: (behavior) =>
        _nightModeBehaviorDescription(behavior, translations),
    onSelected: settingsController.setNightModeBehavior,
  );
}

Future<void> _showSelectionDialog<T>({
  required BuildContext context,
  required String title,
  required Iterable<T> values,
  required T currentValue,
  required String Function(T value) labelFor,
  String Function(T value)? descriptionFor,
  required Future<void> Function(T value) onSelected,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: values
              .map((value) {
                final description = descriptionFor?.call(value);
                return ListTile(
                  title: Text(labelFor(value)),
                  subtitle: description == null
                      ? null
                      : Text(
                          description,
                          style: TextStyle(
                            color: Theme.of(
                              dialogContext,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                  trailing: value == currentValue
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () async {
                    await onSelected(value);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                );
              })
              .toList(growable: false),
        ),
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
