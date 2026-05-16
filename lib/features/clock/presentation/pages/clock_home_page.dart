import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/clock/application/clock_controller.dart';
import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/domain/night_clock_display_config.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_panel.dart';
import 'package:lunadial/features/clock/presentation/widgets/burn_in_protection_layer.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/features/clock/presentation/widgets/fullscreen_exit_button.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/presentation/pages/settings_page.dart';
import 'package:lunadial/l10n/app_localizations.dart';
import 'package:lunadial/shared/presentation/app_theme_utils.dart';

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage> {
  late final ClockController _clockController = ClockController();
  late final FullscreenExitButtonController _fullscreenExitController =
      FullscreenExitButtonController();

  @override
  void dispose() {
    _fullscreenExitController.dispose();
    _clockController.dispose();
    super.dispose();
  }

  void _enterFullscreen(AppSessionController session) {
    _fullscreenExitController.showTemporarily();
    session.setFullscreen(true);
    _persistDedicatedClockState(true);
  }

  void _exitFullscreen(AppSessionController session) {
    _fullscreenExitController.hide();
    session.setFullscreen(false);
    _persistDedicatedClockState(false);
  }

  void _revealFullscreenButton() {
    _fullscreenExitController.showTemporarily();
  }

  void _persistDedicatedClockState(bool isFullscreen) {
    final settingsController = context.read<AppSettingsController>();
    if (!settingsController.settings.dedicatedClockModeEnabled) {
      return;
    }

    settingsController.setRestoreFullscreenOnLaunch(isFullscreen);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>().settings;
    final session = context.watch<AppSessionController>();
    final translations = AppLocalizations.of(context)!;

    if (session.isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          key: const Key('fullscreen-surface'),
          onTap: _revealFullscreenButton,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              _TickingClockContent(
                clockController: _clockController,
                displayMode: settings.clockDisplayMode,
                settings: settings,
              ),
              Positioned(
                top: 20,
                right: 20,
                child: FullscreenExitButton(
                  controller: _fullscreenExitController,
                  onExit: () => _exitFullscreen(session),
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
        backgroundColor: pureBlackAppBarBackground(settings.themeColor),
        actions: [
          Semantics(
            label: translations.enterFullscreenMode,
            button: true,
            child: IconButton(
              key: const Key('enter-fullscreen-button'),
              icon: const Icon(Icons.fullscreen),
              onPressed: () => _enterFullscreen(session),
            ),
          ),
          Semantics(
            label: translations.openSettings,
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
      backgroundColor: pureBlackScaffoldBackground(settings.themeColor),
      body: _TickingClockContent(
        clockController: _clockController,
        displayMode: settings.clockDisplayMode,
        settings: settings,
      ),
    );
  }
}

class _TickingClockContent extends StatelessWidget {
  const _TickingClockContent({
    required this.clockController,
    required this.displayMode,
    required this.settings,
  });

  final ClockController clockController;
  final ClockDisplayMode displayMode;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = constraints.biggest;
        final isLandscape = availableSize.width >= availableSize.height;
        final digitalLayout = resolveDigitalClockLayout(availableSize);
        final analogLayout = resolveAnalogClockLayout(availableSize);

        return AnimatedBuilder(
          animation: clockController,
          builder: (context, _) {
            final displayConfig = NightClockDisplayConfig.resolve(
              settings: settings,
              currentTime: clockController.currentTime,
              platformBrightness: MediaQuery.platformBrightnessOf(context),
              isLandscape: isLandscape,
            );
            final clockContent = displayMode == ClockDisplayMode.digital
                ? DigitalClockView(
                    currentTime: clockController.currentTime,
                    layout: digitalLayout,
                    timeFormatPreference: settings.timeFormatPreference,
                    showSeconds: settings.showSeconds,
                    digitalClockLeadingZero: settings.digitalClockLeadingZero,
                    nightModeEnabled: displayConfig.isNightModeActive,
                    isLandscape: displayConfig.isLandscape,
                  )
                : AnalogClockPanel(
                    currentTime: clockController.currentTime,
                    focusedDay: clockController.focusedDay,
                    selectedDay: clockController.selectedDay,
                    onDaySelected: clockController.selectDay,
                    onPageChanged: clockController.focusDay,
                    layout: analogLayout,
                    showSecondHand: settings.showSeconds,
                    nightModeEnabled: displayConfig.isNightModeActive,
                  );

            return ColoredBox(
              color: displayConfig.isNightModeActive
                  ? Colors.black
                  : Colors.transparent,
              child: BurnInProtectionLayer(
                enabled: displayConfig.shouldUseBurnInProtection,
                child: FadeIn(child: clockContent),
              ),
            );
          },
        );
      },
    );
  }
}
