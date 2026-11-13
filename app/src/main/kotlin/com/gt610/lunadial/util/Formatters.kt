package com.gt610.lunadial.util

import android.content.Context
import android.text.format.DateFormat
import com.gt610.lunadial.model.TimeFormatOption
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/** Resolves whether the 24-hour clock should be used for the current settings. */
fun resolveUse24Hour(context: Context, option: TimeFormatOption): Boolean = when (option) {
  TimeFormatOption.TWENTY_FOUR_HOUR -> true
  TimeFormatOption.TWELVE_HOUR -> false
  TimeFormatOption.SYSTEM -> DateFormat.is24HourFormat(context)
}

/**
 * Builds the clock pattern the same way the Flutter app did: hours, optional
 * seconds, and a locale-appropriate AM/PM placement (Chinese puts it first).
 */
fun clockPattern(
  locale: Locale,
  use24Hour: Boolean,
  showSeconds: Boolean,
  leadingZero: Boolean,
): String {
  if (use24Hour) {
    val hours = if (leadingZero) "HH" else "H"
    val tail = if (showSeconds) ":mm:ss" else ":mm"
    return hours + tail
  }

  val hours = if (leadingZero) "hh" else "h"
  val tail = if (showSeconds) ":mm:ss" else ":mm"
  return if (locale.language == "zh") "a $hours$tail" else "$hours$tail a"
}

fun formatWithPattern(date: Date, pattern: String, locale: Locale): String =
  SimpleDateFormat(pattern, locale).format(date)

fun minutesOfDay(calendar: Calendar): Int =
  calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)

fun formatMinutesOfDay(minutesOfDay: Int, use24Hour: Boolean, locale: Locale): String {
  val normalized = ((minutesOfDay % (24 * 60)) + 24 * 60) % (24 * 60)
  val date = Calendar.getInstance().apply {
    set(Calendar.HOUR_OF_DAY, normalized / 60)
    set(Calendar.MINUTE, normalized % 60)
    set(Calendar.SECOND, 0)
  }.time
  val pattern = if (use24Hour) {
    "HH:mm"
  } else if (locale.language == "zh") {
    "a h:mm"
  } else {
    "h:mm a"
  }
  return formatWithPattern(date, pattern, locale)
}

/** Single-letter weekday labels ordered Sunday first, for the compact grid. */
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

/** Weekday abbreviations ordered Sunday first, matching the calendar grid. */
fun weekdayLabels(locale: Locale): List<String> {
  val format = SimpleDateFormat("EEE", locale)
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
  val firstWeekdayIndex = calendar.get(Calendar.DAY_OF_WEEK) - Calendar.SUNDAY
  val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)
  val cells = ArrayList<Int?>(42)
  repeat(firstWeekdayIndex.coerceAtLeast(0)) { cells.add(null) }
  for (day in 1..daysInMonth) cells.add(day)
  while (cells.size % 7 != 0) cells.add(null)
  return cells
}

fun isSameDay(left: Calendar?, year: Int, month: Int, day: Int): Boolean {
  if (left == null) return false
  return left.get(Calendar.YEAR) == year &&
    left.get(Calendar.MONTH) == month &&
    left.get(Calendar.DAY_OF_MONTH) == day
}
