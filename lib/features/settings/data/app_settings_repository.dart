import 'package:lunadial/features/settings/domain/app_settings.dart';

abstract class AppSettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
