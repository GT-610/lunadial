import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/clock/application/clock_controller.dart';
import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_panel.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/features/clock/presentation/widgets/fullscreen_exit_button.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/presentation/pages/settings_page.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage> {
  late final ClockController _clockController = ClockController();
  bool _fullscreenButtonSignal = false;

  @override
  void dispose() {
    _clockController.dispose();
    super.dispose();
  }

  void _revealFullscreenButton() {
    setState(() {
      _fullscreenButtonSignal = !_fullscreenButtonSignal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>().settings;
    final session = context.watch<AppSessionController>();
    final translations = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final fontSize = calculateDigitalFontSize(size);
    final isBlackTheme = settings.themeColor == Colors.black;

    return AnimatedBuilder(
      animation: _clockController,
      builder: (context, _) {
        final clockContent =
            settings.clockDisplayMode == ClockDisplayMode.digital
            ? DigitalClockView(
                currentTime: _clockController.currentTime,
                fontSize: fontSize,
              )
            : AnalogClockPanel(
                currentTime: _clockController.currentTime,
                focusedDay: _clockController.focusedDay,
                selectedDay: _clockController.selectedDay,
                onDaySelected: _clockController.selectDay,
                onPageChanged: _clockController.focusDay,
              );

        final content = FadeIn(child: clockContent);

        if (session.isFullscreen) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: GestureDetector(
              onTap: _revealFullscreenButton,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  Center(child: content),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: FullscreenExitButton(
                      visibleSignal: _fullscreenButtonSignal,
                      onExit: session.toggleFullscreen,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(translations.appTitle),
            backgroundColor: isBlackTheme ? Colors.grey.shade900 : null,
            actions: [
              Semantics(
                label: 'Enter fullscreen mode',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: session.toggleFullscreen,
                ),
              ),
              Semantics(
                label: 'Open settings',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          backgroundColor: isBlackTheme ? Colors.black : null,
          body: Center(child: content),
        );
      },
    );
  }
}
