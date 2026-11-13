package com.gt610.lunadial.data

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit
import com.gt610.lunadial.model.AppSettings
import com.gt610.lunadial.model.ClockDisplayMode
import com.gt610.lunadial.model.LocaleOption
import com.gt610.lunadial.model.NightModeBehavior
import com.gt610.lunadial.model.ThemeModeOption
import com.gt610.lunadial.model.TimeFormatOption
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Single source of truth for [AppSettings]. Preferences are written eagerly and
 * read once at construction, which keeps the clock screen free of async loading
 * states.
 */
class SettingsStore(context: Context) {

  private val prefs: SharedPreferences =
    context.applicationContext.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

  private val _settings = MutableStateFlow(read())
  val settings: StateFlow<AppSettings> = _settings.asStateFlow()

  val current: AppSettings get() = _settings.value

  /** Applies [transform] and persists the result if anything changed. */
  fun update(transform: (AppSettings) -> AppSettings) {
    val previous = _settings.value
    val next = transform(previous)
    if (next == previous) return
    _settings.value = next
    write(next)
  }

  private fun read(): AppSettings {
    val defaults = AppSettings()
    return AppSettings(
      themeColor = prefs.getInt(KEY_THEME_COLOR, defaults.themeColor),
      useDynamicColor = prefs.getBoolean(KEY_USE_DYNAMIC_COLOR, defaults.useDynamicColor),
      themeMode = enum(prefs.getString(KEY_THEME_MODE, null), defaults.themeMode),
      keepScreenOn = prefs.getBoolean(KEY_KEEP_SCREEN_ON, defaults.keepScreenOn),
      clockDisplayMode = enum(
        prefs.getString(KEY_CLOCK_DISPLAY_MODE, null),
        defaults.clockDisplayMode,
      ),
      locale = enum(prefs.getString(KEY_LOCALE, null), defaults.locale),
      timeFormat = enum(prefs.getString(KEY_TIME_FORMAT, null), defaults.timeFormat),
      showSeconds = prefs.getBoolean(KEY_SHOW_SECONDS, defaults.showSeconds),
      leadingZero = prefs.getBoolean(KEY_LEADING_ZERO, defaults.leadingZero),
      nightMode = enum(prefs.getString(KEY_NIGHT_MODE, null), defaults.nightMode),
      nightStartMinutes = prefs.getInt(KEY_NIGHT_START, defaults.nightStartMinutes),
      nightEndMinutes = prefs.getInt(KEY_NIGHT_END, defaults.nightEndMinutes),
      burnInProtection = prefs.getBoolean(KEY_BURN_IN, defaults.burnInProtection),
    )
  }

  private fun write(settings: AppSettings) {
    prefs.edit {
      putInt(KEY_THEME_COLOR, settings.themeColor)
      putBoolean(KEY_USE_DYNAMIC_COLOR, settings.useDynamicColor)
      putString(KEY_THEME_MODE, settings.themeMode.name)
      putBoolean(KEY_KEEP_SCREEN_ON, settings.keepScreenOn)
      putString(KEY_CLOCK_DISPLAY_MODE, settings.clockDisplayMode.name)
      putString(KEY_LOCALE, settings.locale.name)
      putString(KEY_TIME_FORMAT, settings.timeFormat.name)
      putBoolean(KEY_SHOW_SECONDS, settings.showSeconds)
      putBoolean(KEY_LEADING_ZERO, settings.leadingZero)
      putString(KEY_NIGHT_MODE, settings.nightMode.name)
      putInt(KEY_NIGHT_START, settings.nightStartMinutes)
      putInt(KEY_NIGHT_END, settings.nightEndMinutes)
      putBoolean(KEY_BURN_IN, settings.burnInProtection)
    }
  }

  private inline fun <reified T : Enum<T>> enum(value: String?, fallback: T): T =
    entryOrNull<T>(value) ?: fallback

  private inline fun <reified T : Enum<T>> entryOrNull(value: String?): T? =
    value?.let { name -> enumValues<T>().firstOrNull { it.name == name } }

  private companion object {
    const val FILE_NAME = "lunadial_settings"
    const val KEY_THEME_COLOR = "themeColor"
    const val KEY_USE_DYNAMIC_COLOR = "useDynamicColor"
    const val KEY_THEME_MODE = "themeMode"
    const val KEY_KEEP_SCREEN_ON = "keepScreenOn"
    const val KEY_CLOCK_DISPLAY_MODE = "clockDisplayMode"
    const val KEY_LOCALE = "locale"
    const val KEY_TIME_FORMAT = "timeFormat"
    const val KEY_SHOW_SECONDS = "showSeconds"
    const val KEY_LEADING_ZERO = "leadingZero"
    const val KEY_NIGHT_MODE = "nightMode"
    const val KEY_NIGHT_START = "nightStartMinutes"
    const val KEY_NIGHT_END = "nightEndMinutes"
    const val KEY_BURN_IN = "burnInProtection"
  }
}

/** Kept for readability at call sites that only need the display enums. */
internal fun ClockDisplayMode.isDigital(): Boolean = this == ClockDisplayMode.DIGITAL

internal fun NightModeBehavior.isActiveAt(
  minutesOfDay: Int,
  startMinutes: Int,
  endMinutes: Int,
): Boolean = when (this) {
  NightModeBehavior.OFF -> false
  NightModeBehavior.ON -> true
  NightModeBehavior.FOLLOW_SYSTEM -> false
  NightModeBehavior.SCHEDULED -> isWithinNightWindow(minutesOfDay, startMinutes, endMinutes)
}

/**
 * True when [minutesOfDay] falls inside the half-open window
 * [startMinutes, endMinutes). A window whose ends coincide covers the whole day,
 * and a window that runs past midnight wraps around, exactly like the Flutter
 * implementation.
 */
fun isWithinNightWindow(minutesOfDay: Int, startMinutes: Int, endMinutes: Int): Boolean {
  if (startMinutes == endMinutes) return true
  return if (startMinutes < endMinutes) {
    minutesOfDay >= startMinutes && minutesOfDay < endMinutes
  } else {
    minutesOfDay >= startMinutes || minutesOfDay < endMinutes
  }
}
