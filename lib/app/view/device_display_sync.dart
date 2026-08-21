import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_synchronizeDisplayState());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_synchronizeDisplayState());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _synchronizeDisplayState() async {
    if (!_isAndroidDevice) {
      return;
    }

    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {
      // Display preferences are best-effort and must not prevent app startup.
    }

    try {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    } catch (_) {
      // Display preferences are best-effort and must not prevent app startup.
    }
  }

  bool get _isAndroidDevice =>
      !kIsWeb &&
      (widget.debugPlatformOverride ?? defaultTargetPlatform) ==
          TargetPlatform.android;

  @override
  Widget build(BuildContext context) => widget.child;
}
