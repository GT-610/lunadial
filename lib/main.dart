import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: const MyApp(),
    ),
  );
}

class AppData extends ChangeNotifier {
  List<WidgetData> widgets = [
    WidgetData(type: 'clock', x: 0.0, y: 0.0),
  ];

  Color _selectedColor = Colors.green;

  Color get selectedColor => _selectedColor;

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void addWidget(String type) {
    widgets.add(WidgetData(type: type, x: 0.0, y: 0.0));
    notifyListeners();
  }

  void removeWidget(WidgetData widget) {
    widgets.remove(widget);
    notifyListeners();
  }

  void updateWidgetPosition(WidgetData widget, double x, double y) {
    widget.x = x;
    widget.y = y;
    notifyListeners();
  }
}

class WidgetData {
  String type;
  double x;
  double y;

  WidgetData({required this.type, required this.x, required this.y});
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
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: appData.widgets.map((widgetData) {
              if (widgetData.type == 'clock') {
                return DraggableClock(
                  widgetData: widgetData,
                  constraints: constraints,
                );
              }
              return Container(); // Placeholder for other widget types
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWidgetDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }

  void _showAddWidgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Widget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Clock'),
                onTap: () {
                  Provider.of<AppData>(context, listen: false).addWidget('clock');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class DraggableClock extends StatefulWidget {
  final WidgetData widgetData;
  final BoxConstraints constraints;

  const DraggableClock({Key? key, required this.widgetData, required this.constraints}) : super(key: key);

  @override
  State<DraggableClock> createState() => _DraggableClockState();
}

class _DraggableClockState extends State<DraggableClock> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      final now = DateTime.now();
      final weekday = DateFormat('EEEE').format(now);
      final dateTime = DateFormat('yyyy-MM-dd \nHH:mm:ss').format(now);
      _currentTime = '$weekday\n$dateTime';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return Positioned(
      left: widget.widgetData.x,
      top: widget.widgetData.y,
      child: GestureDetector(
        onLongPress: () {
          _showDeleteWidgetDialog(context, widget.widgetData);
        },
        child: Draggable(
          feedback: Material(
            child: Text(
              _currentTime,
              style: const TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          ),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            double x = details.offset.dx;
            double y = details.offset.dy;

            // Keep the widget within the bounds of the screen
            if (x < 0) x = 0;
            if (y < 0) y = 0;
            if (x > widget.constraints.maxWidth - 100) x = widget.constraints.maxWidth - 100; // subtracting width of text
            if (y > widget.constraints.maxHeight - 100) y = widget.constraints.maxHeight - 100; // subtracting height of text

            appData.updateWidgetPosition(widget.widgetData, x, y);
          },
          child: Text(
            _currentTime,
            style: const TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showDeleteWidgetDialog(BuildContext context, WidgetData widgetData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Widget?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Provider.of<AppData>(context, listen: false).removeWidget(widgetData);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
                    content: const Text("Desuclock \n Version: 0.01-A"),
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