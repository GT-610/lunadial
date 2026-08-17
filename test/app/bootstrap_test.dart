import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/app/bootstrap.dart';
import 'package:lunadial/shared/application/app_error_controller.dart';

void main() {
  testWidgets('framework errors do not replace the app with a global error', (
    tester,
  ) async {
    final previousFlutterErrorHandler = FlutterError.onError;
    final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = previousFlutterErrorHandler;
      PlatformDispatcher.instance.onError = previousPlatformErrorHandler;
    });

    final controller = AppErrorController();
    FlutterErrorDetails? reportedDetails;
    configureErrorHandlers(
      errorController: controller,
      frameworkErrorHandler: (details) => reportedDetails = details,
    );

    final details = FlutterErrorDetails(
      exception: FlutterError('transient layout failure'),
    );
    FlutterError.onError!(details);

    expect(reportedDetails, same(details));
    expect(controller.state, isNull);
  });

  testWidgets('unhandled platform errors still open the global error page', (
    tester,
  ) async {
    final previousFlutterErrorHandler = FlutterError.onError;
    final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = previousFlutterErrorHandler;
      PlatformDispatcher.instance.onError = previousPlatformErrorHandler;
    });

    final controller = AppErrorController();
    configureErrorHandlers(
      errorController: controller,
      frameworkErrorHandler: (_) {},
    );

    final error = StateError('unhandled asynchronous failure');
    final stackTrace = StackTrace.current;
    final handled = PlatformDispatcher.instance.onError!(error, stackTrace);

    expect(handled, isTrue);
    expect(controller.state?.error, same(error));
    expect(controller.state?.stackTrace, same(stackTrace));
  });
}
