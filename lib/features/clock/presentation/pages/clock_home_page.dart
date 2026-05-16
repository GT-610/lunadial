import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/luna_dial_app.dart';
import 'package:lunadial/features/clock/application/clock_controller.dart';
import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/domain/night_clock_display_config.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_panel.dart';
import 'package:lunadial/features/clock/presentation/widgets/burn_in_protection_layer.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/features/clock/presentation/widgets/settings_reveal_button.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/presentation/pages/settings_page.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage> with RouteAware {
  late final ClockController _clockController = ClockController();
  late final SettingsButtonController _settingsButtonController =
      SettingsButtonController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _settingsButtonController.dispose();
    _clockController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    _clockController.stopTicker();
  }

  @override
  void didPopNext() {
    _clockController.resumeTicker();
  }

  void _onScreenTap() {
    if (_settingsButtonController.isVisible) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
    } else {
      _settingsButtonController.showTemporarily();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>().settings;
    final translations = AppLocalizations.of(context)!;
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      body: GestureDetector(
        key: const Key('clock-surface'),
        onTap: _onScreenTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            _TickingClockContent(
              clockController: _clockController,
              displayMode: settings.clockDisplayMode,
              settings: settings,
            ),
            Positioned(
              top: padding.top + 20,
              left: 20,
              right: 20,
              child: _TopBar(
                controller: _settingsButtonController,
                title: translations.appTitle,
                onSettings: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

            return RepaintBoundary(
              child: ColoredBox(
                color: displayConfig.isNightModeActive
                    ? Colors.black
                    : Colors.transparent,
                child: BurnInProtectionLayer(
                  enabled: displayConfig.shouldUseBurnInProtection,
                  child: FadeIn(child: clockContent),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.controller,
    required this.title,
    required this.onSettings,
  });

  final SettingsButtonController controller;
  final String title;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IgnorePointer(
          ignoring: !controller.isVisible,
          child: AnimatedOpacity(
            opacity: controller.isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SettingsRevealButton(controller: controller, onTap: onSettings),
              ],
            ),
          ),
        );
      },
    );
  }
}
