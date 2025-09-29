import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_data.dart';
import 'about_page.dart';
import 'dart:io' show Platform;
import '../utils/settings_manager.dart';

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
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class ColorSelectionGrid extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color selectedColor;

  const ColorSelectionGrid({
    Key? key,
    required this.onColorSelected,
    required this.selectedColor,
  }) : super(key: key);

  final List<Color> colorOptions = const [
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
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colorOptions.map((color) {
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color == selectedColor ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: color == selectedColor
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    
    return WillPopScope(
      onWillPop: () async {
        // 在页面返回时保存配置
        print('[DEBUG] 正在触发保存操作...');
        await SettingsManager.saveSettings(appData.toMap());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: appData.selectedColor == Colors.black ? Colors.grey[900] : null,
        ),
        body: ListView(
          children: <Widget>[
            // Appearance section
            Column(
              children: [
                ListTile(
                  title: const Text('Theme Color'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: appData.selectedColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Select Theme Color'),
                          content: SingleChildScrollView(
                            child: Container(
                              width: 300,
                              padding: const EdgeInsets.all(10.0),
                              child: ColorSelectionGrid(
                                onColorSelected: (color) {
                                  appData.setSelectedColor(color);
                                  Navigator.of(context).pop();
                                },
                                selectedColor: appData.selectedColor,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Column(
              children: [
                ListTile(
                  title: const Text('Theme mode'),
                  trailing: ThemeModeSelectionDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            
            // 屏幕常亮设置
            if (Platform.isAndroid)
              Column(
                children: [
                  ListTile(
                    title: const Text('Keep Screen On'),
                    trailing: Switch(
                      value: appData.keepScreenOn,
                      onChanged: (value) {
                        appData.setKeepScreenOn(value);
                      },
                    ),
                  ),
                ],
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
      ),
    );
  }
}
