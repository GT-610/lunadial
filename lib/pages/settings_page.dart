import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_data.dart';
import 'about_page.dart';
import 'dart:io' show Platform;
import '../utils/settings_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isBlackTheme = appData.selectedColor == Colors.black;
    
    return WillPopScope(
      onWillPop: () async {
        print('[DEBUG] 正在触发保存操作...');
        await SettingsManager.saveSettings(appData.toMap());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
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
                title: 'Appearance',
                subtitle: 'Customize the look and feel of LunaDial',
                children: [
                  _buildSettingItem(
                    context,
                    title: 'Theme Color',
                    description: 'Choose the primary color for the clock',
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
                    title: 'Theme Mode',
                    description: 'Choose between light, dark, or system theme',
                    trailing: _buildThemeModeDropdown(context, appData),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (Platform.isAndroid)
                _buildSettingsCard(
                  context,
                  title: 'Screen',
                  subtitle: 'Configure screen behavior',
                  children: [
                    _buildSettingItem(
                      context,
                      title: 'Keep Screen On',
                      description: 'Prevent the screen from turning off',
                      trailing: Switch(
                        value: appData.keepScreenOn,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          appData.setKeepScreenOn(value);
                        },
                      ),
                    ),
                  ],
                ),
              
              if (Platform.isAndroid) const SizedBox(height: 24),
              
              _buildSettingsCard(
                context,
                title: 'Clock Style',
                subtitle: 'Change how the time is displayed',
                children: [
                  _buildSettingItem(
                    context,
                    title: 'Digital Clock',
                    description: 'Use digital format instead of analog',
                    trailing: Switch(
                      value: appData.isDigitalClock,
                      activeColor: Theme.of(context).colorScheme.primary,
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
                title: 'Information',
                subtitle: 'Learn more about LunaDial',
                children: [
                  _buildSettingItem(
                    context,
                    title: 'About',
                    description: 'Version, license, and more information',
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
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
    return DropdownButton<ThemeMode>(
      value: appData.themeMode,
      dropdownColor: Theme.of(context).colorScheme.surface,
      underline: Container(),
      items: const [
        DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
        DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
        DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
      ],
      onChanged: (ThemeMode? value) {
        if (value != null) {
          appData.setThemeMode(value);
        }
      },
    );
  }
  
  void _showColorPickerDialog(BuildContext context, AppData appData) {
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
              Text('Select Theme Color', style: Theme.of(context).textTheme.headlineSmall),
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
