import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextSettings = context.read<AppSettingsController>();

    if (!identical(_settingsController, nextSettings)) {
      _settingsController?.removeListener(_handleStateChange);
      _settingsController = nextSettings..addListener(_handleStateChange);
    }

    _synchronizeDisplayState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _synchronizeDisplayState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsController?.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    _synchronizeDisplayState();
  }

  Future<void> _synchronizeDisplayState() async {
    if (!_isAndroidDevice) {
      return;
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  bool get _isAndroidDevice =>
      !kIsWeb &&
      (widget.debugPlatformOverride ?? defaultTargetPlatform) ==
          TargetPlatform.android;

  @override
  Widget build(BuildContext context) => widget.child;
}
