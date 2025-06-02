import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_data.dart';
import 'about_page.dart';
import 'dart:io' show Platform;

/// Dropdown for selecting theme modes.
class ThemeModeSelectionDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return DropdownButton<ThemeMode>(
      value: appData.themeMode,
      items: const [
        DropdownMenuItem(
          value: ThemeMode.system,
          child: Text('System'),
        ),
        DropdownMenuItem(
          value: ThemeMode.light,
          child: Text('Light'),
        ),
        DropdownMenuItem(
          value: ThemeMode.dark,
          child: Text('Dark'),
        ),
      ],
      onChanged: (ThemeMode? value) {
        if (value != null) {
          appData.setThemeMode(value);
        }
      },
    );
  }
}

/// Settings page for customizing application preferences.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: appData.selectedColor == Colors.black ? Colors.grey[900] : null,
      ),
      body: ListView(
        children: <Widget>[
          // Appearance section
          ListTile(
            title: const Text('Theme Color'),
            trailing: ColorSelectionDropdown(),
          ),
          ListTile(
            title: const Text('Theme Mode'),
            trailing: ThemeModeSelectionDropdown(),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          
          // 修改屏幕常亮设置项为不可用状态
          if (Platform.isAndroid)
            ListTile(
              title: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: 'Screen Wake Lock\n'),
                    TextSpan(
                      text: 'Coming soon',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Switch(
                value: false, // 强制保持关闭状态
                activeColor: Colors.grey,
                inactiveThumbColor: Colors.grey,
                onChanged: null, // 禁用交互
              ),
            ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          
          // Clock Style section
          ListTile(
            title: const Text('Digital Clock'),
            trailing: Switch(
              value: appData.isDigitalClock,
              onChanged: (value) {
                appData.toggleClockStyle();
              },
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          
          // About section
          ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),

        ],
      ),
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }
}

/// Dropdown for selecting theme colors.
class ColorSelectionDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return DropdownButton<Color>(
      value: appData.selectedColor,
      items: const [
        DropdownMenuItem(
          value: Colors.red,
          child: Text('Red'),
        ),
        DropdownMenuItem(
          value: Colors.green,
          child: Text('Green'),
        ),
        DropdownMenuItem(
          value: Colors.blue,
          child: Text('Blue'),
        ),
        DropdownMenuItem(
          value: Colors.purple,
          child: Text('Purple'),
        ),
        DropdownMenuItem(
          value: Colors.amber,
          child: Text('Amber'),
        ),
        DropdownMenuItem(
          value: Colors.black,
          child: Text('Pure black'),
        ),
      ],
      onChanged: (Color? value) {
        if (value != null) {
          appData.setSelectedColor(value);
        }
      },
    );
  }
}