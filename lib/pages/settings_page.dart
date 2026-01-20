import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_data.dart';
import '../utils/settings_manager.dart';

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
    setState(() {
      _appVersion = packageInfo.version;
    });
  }
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final translations = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isBlackTheme = appData.selectedColor == Colors.black;
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await SettingsManager.saveSettings(appData.toMap());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(translations.settings),
          backgroundColor: isBlackTheme ? Colors.grey[900] : null,
          elevation: 0,
        ),
        body: Container(
          color: isBlackTheme ? Colors.black : null,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              _buildSettingsCard(
                context,
                title: translations.appearance,
                subtitle: translations.appearanceDescription,
                children: [
                  _buildSettingItem(
                    context,
                    title: translations.themeColor,
                    description: translations.themeColorDescription,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: appData.selectedColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
                      ],
                    ),
                    onTap: () {
                      _showColorPickerDialog(context, appData);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    context,
                    title: translations.themeMode,
                    description: translations.themeModeDescription,
                    trailing: _buildThemeModeDropdown(context, appData),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    context,
                    title: translations.language,
                    description: translations.languageDescription,
                    trailing: _buildLanguageDropdown(context, appData),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildSettingsCard(
                context,
                title: translations.screen,
                subtitle: translations.screenDescription,
                children: [
                  _buildSettingItem(
                    context,
                    title: translations.keepScreenOn,
                    description: translations.keepScreenOnDescription,
                    trailing: Switch(
                      value: appData.keepScreenOn,
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        appData.setKeepScreenOn(value);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSettingsCard(
                context,
                title: translations.clockStyle,
                subtitle: translations.clockStyleDescription,
                children: [
                  _buildSettingItem(
                    context,
                    title: translations.digitalClock,
                    description: translations.digitalClockDescription,
                    trailing: Switch(
                      value: appData.isDigitalClock,
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        appData.toggleClockStyle();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildSettingsCard(
                context,
                title: translations.information,
                subtitle: translations.informationDescription,
                children: [
                  _buildSettingItem(
                    context,
                    title: translations.version,
                    description: translations.versionDescription,
                    trailing: Text(
                      _appVersion,
                      style: TextStyle(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    context,
                    title: translations.license,
                    description: translations.licenseDescription,
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildInfoDialog(
                          title: translations.license,
                          content: 'GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007\n\nThis program is free software: you can redistribute it and/or modify\nit under the terms of the GNU General Public License as published by\nthe Free Software Foundation, either version 3 of the License, or\n(at your option) any later version.\n\nThis program is distributed in the hope that it will be useful,\nbut WITHOUT ANY WARRANTY; without even the implied warranty of\nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\nGNU General Public License for more details.\n\nYou should have received a copy of the GNU General Public License\nalong with this program.  If not, see <https://www.gnu.org/licenses/>.',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    context,
                    title: translations.contributors,
                    description: translations.contributorsDescription,
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildInfoDialog(
                          title: translations.contributors,
                          content: 'Contributors list placeholder\n\nMore contributors will be added here.',
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildThemeModeDropdown(BuildContext context, AppData appData) {
    final translations = AppLocalizations.of(context)!;
    return DropdownButton<ThemeMode>(
      value: appData.themeMode,
      dropdownColor: Theme.of(context).colorScheme.surface,
      underline: Container(),
      items: [
        DropdownMenuItem(value: ThemeMode.system, child: Text(translations.system)),
        DropdownMenuItem(value: ThemeMode.light, child: Text(translations.light)),
        DropdownMenuItem(value: ThemeMode.dark, child: Text(translations.dark)),
      ],
      onChanged: (ThemeMode? value) {
        if (value != null) {
          appData.setThemeMode(value);
        }
      },
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, AppData appData) {
    final translations = AppLocalizations.of(context)!;
    return DropdownButton<String>(
      value: appData.selectedLocale,
      dropdownColor: Theme.of(context).colorScheme.surface,
      underline: Container(),
      items: [
        DropdownMenuItem(value: 'system', child: Text(translations.system)),
        DropdownMenuItem(value: 'en', child: Text(translations.english)),
        DropdownMenuItem(value: 'zh_CN', child: Text(translations.chinese)),
      ],
      onChanged: (String? value) {
        if (value != null) {
          appData.setLocale(value);
        }
      },
    );
  }
  
  Widget _buildInfoDialog({
    required String title,
    required String content,
  }) {
    final translations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(content),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(translations.close),
        ),
      ],
    );
  }
  
  void _showColorPickerDialog(BuildContext context, AppData appData) {
    final translations = AppLocalizations.of(context)!;
    final List<Color> colorOptions = const [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    ];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translations.selectThemeColor, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: colorOptions.map((color) {
                  final isSelected = color == appData.selectedColor;
                  return GestureDetector(
                    onTap: () {
                      appData.setSelectedColor(color);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary, size: 22)
                        : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Column(children: children),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingItem(BuildContext context, {
    required String title,
    required String description,
    required Widget trailing,
    void Function()? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
