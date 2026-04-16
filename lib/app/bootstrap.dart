import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/luna_dial_app.dart';
import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/json_app_settings_repository.dart';

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = AppSettingsController(
    repository: const JsonAppSettingsRepository(),
  );
  await settingsController.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettingsController>.value(
          value: settingsController,
        ),
        ChangeNotifierProvider<AppSessionController>(
          create: (_) => AppSessionController(),
        ),
      ],
      child: const LunaDialApp(),
    ),
  );
}
