import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/luna_dial_app.dart';
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

  configureErrorHandlers(errorController: errorController);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppErrorController>.value(
          value: errorController,
        ),
        ChangeNotifierProvider<AppSettingsController>.value(
          value: settingsController,
        ),
      ],
      child: const LunaDialApp(),
    ),
  );
}

@visibleForTesting
void configureErrorHandlers({
  required AppErrorController errorController,
  FlutterExceptionHandler? frameworkErrorHandler,
}) {
  // Framework errors are already rendered or reported by Flutter. Promoting
  // every layout/build error to the global error page can replace an otherwise
  // usable screen during a transient rebuild.
  FlutterError.onError = frameworkErrorHandler ?? FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    errorController.showError(error, stackTrace);
    return true;
  };
}
