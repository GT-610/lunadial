enum TimeFormatPreference { system, twelveHour, twentyFourHour }

extension TimeFormatPreferenceStorage on TimeFormatPreference {
  String get storageValue {
    switch (this) {
      case TimeFormatPreference.system:
        return 'system';
      case TimeFormatPreference.twelveHour:
        return '12h';
      case TimeFormatPreference.twentyFourHour:
        return '24h';
    }
  }

  static TimeFormatPreference fromStorageValue(Object? value) {
    if (value is! String) {
      return TimeFormatPreference.system;
    }

    switch (value) {
      case '12h':
        return TimeFormatPreference.twelveHour;
      case '24h':
        return TimeFormatPreference.twentyFourHour;
      case 'system':
      default:
        return TimeFormatPreference.system;
    }
  }
}
