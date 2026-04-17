import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/luna_dial_app.dart';
import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/json_app_settings_repository.dart';
import 'package:lunadial/shared/application/app_error_controller.dart';

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final errorController = AppErrorController();
  final settingsController = AppSettingsController(
    repository: const JsonAppSettingsRepository(),
  );
  await settingsController.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorController.reportFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    errorController.showError(error, stackTrace);
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppErrorController>.value(
          value: errorController,
        ),
        ChangeNotifierProvider<AppSettingsController>.value(
          value: settingsController,
        ),
        ChangeNotifierProvider<AppSessionController>(
          create: (_) => AppSessionController(
            initialFullscreen:
                settingsController.settings.shouldLaunchToFullscreen,
          ),
        ),
      ],
      child: const LunaDialApp(),
    ),
  );
}
