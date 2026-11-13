package com.gt610.lunadial.util

import android.content.Context
import android.text.format.DateFormat
import com.gt610.lunadial.model.TimeFormatOption
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

private const val MINUTES_PER_DAY = 24 * 60

/** Languages that put the AM/PM marker before the time. */
private val AM_PM_FIRST_LANGUAGES = setOf("zh", "ja", "ko")

/** Resolves whether the 24-hour clock should be used for the current settings. */
fun resolveUse24Hour(context: Context, option: TimeFormatOption): Boolean = when (option) {
  TimeFormatOption.TWENTY_FOUR_HOUR -> true
  TimeFormatOption.TWELVE_HOUR -> false
  TimeFormatOption.SYSTEM -> DateFormat.is24HourFormat(context)
}

/** True when this locale writes the time as "上午 9:05" rather than "9:05 AM". */
private fun amPmFirst(locale: Locale): Boolean = locale.language in AM_PM_FIRST_LANGUAGES

/**
 * Builds a [SimpleDateFormat] pattern for the clock face: hours, optional
 * seconds, and a locale-appropriate AM/PM placement.
 */
fun clockPattern(
  locale: Locale,
  use24Hour: Boolean,
  showSeconds: Boolean,
  leadingZero: Boolean,
): String {
  val tail = if (showSeconds) ":mm:ss" else ":mm"
  if (use24Hour) {
    return (if (leadingZero) "HH" else "H") + tail
  }
  val hours = if (leadingZero) "hh" else "h"
  return if (amPmFirst(locale)) "a $hours$tail" else "$hours$tail a"
}

fun formatWithPattern(date: Date, pattern: String, locale: Locale): String =
  SimpleDateFormat(pattern, locale).format(date)

fun minutesOfDay(calendar: Calendar): Int =
  calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)

/**
 * Formats a "minutes since midnight" preference for display. The value is
 * rendered on a fixed date so that a daylight-saving transition can never shift
 * the wall-clock time the user picked.
 */
fun formatMinutesOfDay(minutesOfDay: Int, use24Hour: Boolean, locale: Locale): String {
  val normalized = Math.floorMod(minutesOfDay, MINUTES_PER_DAY)
  val reference = Calendar.getInstance().apply {
    clear()
    set(1970, Calendar.JANUARY, 1, normalized / 60, normalized % 60)
  }.time
  val pattern = when {
    use24Hour -> "HH:mm"
    amPmFirst(locale) -> "a h:mm"
    else -> "h:mm a"
  }
  return formatWithPattern(reference, pattern, locale)
}

/**
 * Single-letter weekday labels ordered Sunday first. The narrow form is "S",
 * "M", … in English and 日, 一, … in Chinese.
 */
fun weekdayNarrowLabels(locale: Locale): List<String> {
  val format = SimpleDateFormat("EEEEE", locale)
  val calendar = Calendar.getInstance()
  calendar.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY)
  return (0 until 7).map {
    val label = format.format(calendar.time)
    calendar.add(Calendar.DAY_OF_MONTH, 1)
    label
  }
}

/**
 * Cells for one month: leading nulls for the blank days before the first of the
 * month, then day numbers. Always a whole number of weeks.
 */
fun monthCells(month: Calendar): List<Int?> {
  val calendar = month.clone() as Calendar
  calendar.set(Calendar.DAY_OF_MONTH, 1)
  // DAY_OF_WEEK is 1..7 with SUNDAY first, so the offset is always 0..6.
  val firstWeekdayIndex = calendar.get(Calendar.DAY_OF_WEEK) - Calendar.SUNDAY
  val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)
  val cells = ArrayList<Int?>(42)
  repeat(firstWeekdayIndex) { cells.add(null) }
  for (day in 1..daysInMonth) cells.add(day)
  while (cells.size % 7 != 0) cells.add(null)
  return cells
}
