// Analog clock demo
// Needs to be integrated into the main app as a widget.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ClockColorData(),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class ClockColorData extends ChangeNotifier {
  Color _selectedColor = Colors.indigo;

  Color get selectedColor => _selectedColor;

  void changeColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analog Clock',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Provider.of<ClockColorData>(context).selectedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Provider.of<ClockColorData>(context).selectedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ClockPage(),
    );
  }
}

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analog Clock')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.35,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CustomPaint(
                        painter:
                            ClockPainter(time: _currentTime, context: context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ColorSelector(),
          ],
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime time;
  final BuildContext context;

  ClockPainter({required this.time, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);
    double radius = math.min(centerX, centerY);

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color onSurface = colorScheme.onSurface;
    final Color surface = colorScheme.surface;
    final Color primary = colorScheme.primary;

    // Draw clock face
    Paint facePaint = Paint()
      ..color = surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Draw minute markers
    Paint minuteMarkerPaint = Paint()
      ..color = onSurface.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 60; i++) {
      double angle = i * math.pi / 30 - math.pi / 2;
      Offset outer = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
      Offset inner = Offset(
        centerX + (radius * 0.95) * math.cos(angle),
        centerY + (radius * 0.95) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, minuteMarkerPaint);
    }

    // Draw hour markers
    Paint hourMarkerPaint = Paint()
      ..color = onSurface
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      double angle = i * math.pi / 6 - math.pi / 2;
      Offset outer = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
      Offset inner = Offset(
        centerX + (radius * 0.9) * math.cos(angle),
        centerY + (radius * 0.9) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, hourMarkerPaint);

      // Draw numbers
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: (i == 0) ? '12' : '${i}',
          style: TextStyle(
            color: onSurface,
            fontSize: 24, // Increased font size
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double numberX = centerX + (radius * 0.75) * math.cos(angle) - textPainter.width / 2;
      double numberY = centerY + (radius * 0.75) * math.sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(numberX, numberY));
    }

    // Hour hand
    double hourAngle =
        (time.hour % 12 + time.minute / 60) * math.pi / 6 - math.pi / 2;
    Offset hourHandEnd = Offset(
      centerX + (radius * 0.6) * math.cos(hourAngle),
      centerY + (radius * 0.6) * math.sin(hourAngle),
    );
    Paint hourHandPaint = Paint()
      ..color = onSurface
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, hourHandEnd, hourHandPaint);

    // Minute hand
    double minuteAngle =
        (time.minute + time.second / 60) * math.pi / 30 - math.pi / 2;
    Offset minuteHandEnd = Offset(
      centerX + (radius * 0.8) * math.cos(minuteAngle),
      centerY + (radius * 0.8) * math.sin(minuteAngle),
    );
    Paint minuteHandPaint = Paint()
      ..color = onSurface
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, minuteHandEnd, minuteHandPaint);

    // Second hand
    double secondAngle = time.second * math.pi / 30 - math.pi / 2;
    Offset secondHandEnd = Offset(
      centerX + (radius * 0.9) * math.cos(secondAngle),
      centerY + (radius * 0.9) * math.sin(secondAngle),
    );
    Paint secondHandPaint = Paint()
      ..color = primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, secondHandEnd, secondHandPaint);

    // Center dot
    Paint centerDotPaint = Paint()..color = onSurface;
    canvas.drawCircle(center, 5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class ColorSelector extends StatelessWidget {
  ColorSelector({super.key});

  final List<Color> availableColors = [
    Colors.indigo,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.blue,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableColors.length,
        itemBuilder: (context, index) {
          final color = availableColors[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Provider.of<ClockColorData>(context, listen: false)
                    .changeColor(color);
              },
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}