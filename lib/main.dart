import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:analog_clock/analog_clock.dart'; // 新增：引入 analog_clock 包

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: const MyApp(),
    ),
  );
}

class AppData extends ChangeNotifier {
  Color _selectedColor = Colors.green;
  bool _isDigitalClock = true; // 新增：用于控制时钟样式，默认为数字时钟

  Color get selectedColor => _selectedColor;
  bool get isDigitalClock => _isDigitalClock; // 新增：获取当前时钟样式

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void toggleClockStyle() { // 新增：切换时钟样式
    _isDigitalClock = !_isDigitalClock;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return MaterialApp(
          title: 'DesuClock',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: appData.selectedColor,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: appData.selectedColor,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
          ),
          themeMode: ThemeMode.system,
          home: const ClockHomePage(),
        );
      },
    );
  }
}

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage> {
  String _currentDate = '';
  String _currentTime = '';

  // 新增方法：根据屏幕尺寸动态计算字体大小
  double _calculateFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.35;
  }

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    setState(() {
      final now = DateTime.now();
      _currentDate = DateFormat('yyyy-MM-dd, EEEE').format(now);
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    // 动态计算字体大小
    final fontSize = _calculateFontSize(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DesuClock'),
        backgroundColor: appData.selectedColor == Colors.black ? Colors.grey[900] : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: appData.isDigitalClock // 根据时钟样式选择显示内容
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentDate,
                    style: TextStyle(fontSize: fontSize * 0.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentTime,
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Row( // 新增：模拟时钟和留空布局
              children: [
                Expanded(
                  child: Center(
                    child: AnalogClock( // 替换为 analog_clock 包中的 AnalogClock 组件
                      decoration: BoxDecoration(
                        border: Border.all(width: 2.0, color: Colors.white),
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      width: 400.0,
                      isLive: true,
                      hourHandColor: Colors.white,
                      minuteHandColor: Colors.white,
                      showSecondHand: true,
                      numberColor: Colors.white,
                      showNumbers: true,
                      showAllNumbers: true,
                      textScaleFactor: 1.4,
                      showTicks: false,
                      showDigitalClock: false,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(), // 空容器，用于留空
                ),
              ],
            ),
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }
}

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
          ListTile(
            title: const Text('About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("About"),
                    content: const Text("Desuclock \n Version: 0.0.1"),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Theme Color'),
            trailing: ColorSelectionDropdown(),
          ),
          ListTile( // 新增：时钟样式切换选项
            title: const Text('Clock Style'),
            trailing: Switch(
              value: appData.isDigitalClock,
              onChanged: (value) {
                appData.toggleClockStyle(); // 切换时钟样式
              },
            ),
          ),
        ],
      ),
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }
}

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