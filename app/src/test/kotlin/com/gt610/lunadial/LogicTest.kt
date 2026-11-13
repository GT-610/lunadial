package com.gt610.lunadial

import com.gt610.lunadial.data.isWithinNightWindow
import com.gt610.lunadial.util.clockPattern
import com.gt610.lunadial.util.monthCells
import com.gt610.lunadial.util.weekdayLabels
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Calendar
import java.util.Locale

class NightWindowTest {

  @Test
  fun `window that crosses midnight covers late and early hours`() {
    val start = 22 * 60
    val end = 7 * 60

    assertTrue(isWithinNightWindow(23 * 60, start, end))
    assertTrue(isWithinNightWindow(0, start, end))
    assertTrue(isWithinNightWindow(6 * 60 + 59, start, end))
    assertFalse(isWithinNightWindow(7 * 60, start, end))
    assertFalse(isWithinNightWindow(12 * 60, start, end))
    assertFalse(isWithinNightWindow(21 * 60 + 59, start, end))
  }

  @Test
  fun `window inside a single day is half open`() {
    assertTrue(isWithinNightWindow(9 * 60, 8 * 60, 17 * 60))
    assertFalse(isWithinNightWindow(8 * 60 - 1, 8 * 60, 17 * 60))
    assertFalse(isWithinNightWindow(17 * 60, 8 * 60, 17 * 60))
  }

  @Test
  fun `identical bounds mean the whole day`() {
    assertTrue(isWithinNightWindow(0, 600, 600))
    assertTrue(isWithinNightWindow(23 * 60 + 59, 600, 600))
  }
}

class ClockPatternTest {

  @Test
  fun `twenty four hour patterns`() {
    assertEquals("HH:mm:ss", clockPattern(Locale.US, use24Hour = true, showSeconds = true, leadingZero = true))
    assertEquals("H:mm", clockPattern(Locale.US, use24Hour = true, showSeconds = false, leadingZero = false))
  }

  @Test
  fun `twelve hour pattern puts am pm last for english`() {
    assertEquals("hh:mm a", clockPattern(Locale.US, use24Hour = false, showSeconds = false, leadingZero = true))
    assertEquals("h:mm:ss a", clockPattern(Locale.US, use24Hour = false, showSeconds = true, leadingZero = false))
  }

  @Test
  fun `twelve hour pattern puts am pm first for chinese`() {
    val zh = Locale.forLanguageTag("zh-CN")
    assertEquals("a hh:mm", clockPattern(zh, use24Hour = false, showSeconds = false, leadingZero = true))
    assertEquals("a h:mm:ss", clockPattern(zh, use24Hour = false, showSeconds = true, leadingZero = false))
  }
}

class CalendarGridTest {

  private fun month(year: Int, monthIndex: Int): Calendar =
    Calendar.getInstance().apply {
      clear()
      set(year, monthIndex, 1)
    }

  @Test
  fun `month starting on sunday has no leading blanks`() {
    // 1 November 2026 is a Sunday.
    val cells = monthCells(month(2026, Calendar.NOVEMBER))
    assertEquals(1, cells.first())
    assertEquals(30, cells.count { it != null })
    assertEquals(0, cells.size % 7)
  }

  @Test
  fun `month starting mid week is padded`() {
    // 1 October 2026 is a Thursday.
    val cells = monthCells(month(2026, Calendar.OCTOBER))
    assertEquals(listOf(null, null, null, null, 1), cells.take(5))
    assertNull(cells[0])
    assertEquals(31, cells.count { it != null })
  }

  @Test
  fun `weekday labels always describe seven days`() {
    assertEquals(7, weekdayLabels(Locale.US).size)
    assertEquals(7, weekdayLabels(Locale.forLanguageTag("zh-CN")).size)
  }
}
