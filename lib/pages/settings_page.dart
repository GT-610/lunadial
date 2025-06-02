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
            
            // 修改屏幕常亮设置项布局结构
            if (Platform.isAndroid)
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Screen Wake Lock'),
                        const SizedBox(height: 4),
                        Text(
                          'Coming soon',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.hourglass_empty, color: Colors.grey),
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

/// Dropdown for selecting theme colors.
class ColorSelectionDropdown extends StatelessWidget {
  // 新增颜色定义列表
  static const List<Map<String, dynamic>> colorsList = [
    {'color': Colors.red, 'name': 'Red'},
    {'color': Colors.green, 'name': 'Green'},
    {'color': Colors.lightGreen, 'name': 'Light Green'},  // 确保浅绿色存在
    {'color': Colors.blue, 'name': 'Blue'},
    {'color': Colors.purple, 'name': 'Purple'},
    {'color': Colors.amber, 'name': 'Amber'},
    {'color': Colors.black, 'name': 'Pure black'},
  ];

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return DropdownButton<Color>(
      value: appData.selectedColor,
      items: [
        // 生成唯一值的菜单项
        for (final entry in colorsList)
          DropdownMenuItem(
            value: entry['color'],
            child: Text(entry['name']),
            // 添加唯一性校验
            key: ValueKey((entry['color'] as Color).value),
          ),
      ],
      onChanged: (Color? value) {
        if (value != null) {
          appData.setSelectedColor(value);
          // 添加颜色变化日志
          print('[COLOR] 颜色已切换至: ${value.toString()}');
        }
      },
    );
  }
}