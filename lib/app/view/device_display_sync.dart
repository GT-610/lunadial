import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';

class DeviceDisplaySync extends StatefulWidget {
  const DeviceDisplaySync({
    super.key,
    required this.child,
    this.debugPlatformOverride,
  });

  final Widget child;
  final TargetPlatform? debugPlatformOverride;

  @override
  State<DeviceDisplaySync> createState() => _DeviceDisplaySyncState();
}

class _DeviceDisplaySyncState extends State<DeviceDisplaySync>
    with WidgetsBindingObserver {
  AppSettingsController? _settingsController;
  AppSessionController? _sessionController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextSettings = context.read<AppSettingsController>();
    final nextSession = context.read<AppSessionController>();

    if (!identical(_settingsController, nextSettings)) {
      _settingsController?.removeListener(_handleStateChange);
      _settingsController = nextSettings..addListener(_handleStateChange);
    }

    if (!identical(_sessionController, nextSession)) {
      _sessionController?.removeListener(_handleStateChange);
      _sessionController = nextSession..addListener(_handleStateChange);
    }

    _synchronizeDisplayState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restoreSessionState();
      _synchronizeDisplayState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsController?.removeListener(_handleStateChange);
    _sessionController?.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    _synchronizeDisplayState();
  }

  void _restoreSessionState() {
    final settings = _settingsController?.settings;
    final session = _sessionController;
    if (settings == null || session == null) {
      return;
    }

    if (settings.shouldLaunchToFullscreen && !session.isFullscreen) {
      session.setFullscreen(true);
    }
  }

  Future<void> _synchronizeDisplayState() async {
    if (!_isAndroidDevice) {
      return;
    }

    final settings = _settingsController?.settings;
    final session = _sessionController;
    if (settings == null || session == null) {
      return;
    }

    await _synchronizeOrientation(settings);
    await _synchronizeSystemUi(settings, session);
  }

  Future<void> _synchronizeOrientation(AppSettings settings) async {
    final shouldPreferLandscape =
        settings.dedicatedClockModeEnabled &&
        settings.preferLandscapeInDedicatedMode;

    await SystemChrome.setPreferredOrientations(
      shouldPreferLandscape
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : DeviceOrientation.values,
    );
  }

  Future<void> _synchronizeSystemUi(
    AppSettings settings,
    AppSessionController session,
  ) async {
    final useDedicatedImmersive =
        settings.dedicatedClockModeEnabled && session.isFullscreen;

    await SystemChrome.setEnabledSystemUIMode(
      useDedicatedImmersive
          ? SystemUiMode.immersiveSticky
          : SystemUiMode.edgeToEdge,
    );
  }

  bool get _isAndroidDevice =>
      !kIsWeb &&
      (widget.debugPlatformOverride ?? defaultTargetPlatform) ==
          TargetPlatform.android;

  @override
  Widget build(BuildContext context) => widget.child;
}
