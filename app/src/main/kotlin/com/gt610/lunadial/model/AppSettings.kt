package com.gt610.lunadial.model

/** How the app resolves its light/dark appearance. */
enum class ThemeModeOption { SYSTEM, LIGHT, DARK, OLED }

/** Which clock face the home screen shows. */
enum class ClockDisplayMode { DIGITAL, ANALOG }

/** Where the hour format comes from. */
enum class TimeFormatOption { SYSTEM, TWELVE_HOUR, TWENTY_FOUR_HOUR }

/** When the calm night presentation is used. */
enum class NightModeBehavior { OFF, ON, SCHEDULED, FOLLOW_SYSTEM }

/** In-app language override. A null tag means "follow the system". */
enum class LocaleOption(val languageTag: String?) {
  SYSTEM(null),
  ENGLISH("en"),
  CHINESE_SIMPLIFIED("zh-CN"),
}

/** Default accent, matching the Flutter app's [Colors.green] seed. */
const val DEFAULT_THEME_COLOR: Int = 0xFF4CAF50.toInt()

/**
 * Every user preference LunaDial stores. Immutable so that the UI can treat a
 * new instance as "the settings changed".
 */
data class AppSettings(
  val themeColor: Int = DEFAULT_THEME_COLOR,
  val useDynamicColor: Boolean = true,
  val themeMode: ThemeModeOption = ThemeModeOption.SYSTEM,
  val keepScreenOn: Boolean = false,
  val clockDisplayMode: ClockDisplayMode = ClockDisplayMode.DIGITAL,
  val locale: LocaleOption = LocaleOption.SYSTEM,
  val timeFormat: TimeFormatOption = TimeFormatOption.SYSTEM,
  val showSeconds: Boolean = true,
  val leadingZero: Boolean = true,
  val nightMode: NightModeBehavior = NightModeBehavior.OFF,
  /** Minutes since midnight, so 22:00 is 1320. */
  val nightStartMinutes: Int = 22 * 60,
  /** Minutes since midnight, so 07:00 is 420. */
  val nightEndMinutes: Int = 7 * 60,
  val burnInProtection: Boolean = true,
) {
  val nightWindowCrossesMidnight: Boolean get() = nightStartMinutes > nightEndMinutes
}

/** Accent presets offered by the theme colour picker. */
val ACCENT_PRESETS: List<Int> = listOf(
  0xFFF44336.toInt(),
  0xFFE91E63.toInt(),
  0xFF9C27B0.toInt(),
  0xFF673AB7.toInt(),
  0xFF3F51B5.toInt(),
  0xFF2196F3.toInt(),
  0xFF00BCD4.toInt(),
  0xFF009688.toInt(),
  0xFF4CAF50.toInt(),
  0xFF8BC34A.toInt(),
  0xFFFFC107.toInt(),
  0xFFFF9800.toInt(),
  0xFFFF5722.toInt(),
  0xFF795548.toInt(),
  0xFF607D8B.toInt(),
)
