import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';

class WakelockSync extends StatefulWidget {
  final Widget child;

  const WakelockSync({super.key, required this.child});

  @override
  State<WakelockSync> createState() => _WakelockSyncState();
}

class _WakelockSyncState extends State<WakelockSync> {
  AppSettingsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = context.read<AppSettingsController>();
    if (_controller == nextController) {
      return;
    }

    _controller?.removeListener(_syncWakelock);
    _controller = nextController;
    _controller?.addListener(_syncWakelock);
    _syncWakelock();
  }

  @override
  void dispose() {
    _controller?.removeListener(_syncWakelock);
    WakelockPlus.disable();
    super.dispose();
  }

  void _syncWakelock() {
    final keepScreenOn = _controller?.settings.keepScreenOn ?? false;
    if (keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
