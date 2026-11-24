package com.gt610.lunadial

import com.gt610.lunadial.data.isWithinNightWindow
import com.gt610.lunadial.model.AppSettings
import com.gt610.lunadial.model.BrightnessMode
import com.gt610.lunadial.model.MAX_BRIGHTNESS
import com.gt610.lunadial.model.MIN_BRIGHTNESS
import com.gt610.lunadial.model.brightnessAfterDrag
import com.gt610.lunadial.model.brightnessPercent
import com.gt610.lunadial.model.effectiveBrightness
import com.gt610.lunadial.model.gestureStartBrightness
import com.gt610.lunadial.model.nightBrightnessActive
import com.gt610.lunadial.util.clockPattern
import com.gt610.lunadial.util.monthCells
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

class BrightnessTest {

  @Test
  fun `following the system means no window override`() {
    val settings = AppSettings(brightnessMode = BrightnessMode.FOLLOW_SYSTEM)
    assertNull(effectiveBrightness(settings, nightActive = false))
  }

  @Test
  fun `custom level applies by day`() {
    val settings = AppSettings(brightnessMode = BrightnessMode.CUSTOM, screenBrightness = 0.4f)
    assertEquals(0.4f, effectiveBrightness(settings, nightActive = false)!!, 0.0001f)
  }

  @Test
  fun `night level wins even when following the system`() {
    val settings = AppSettings(nightAutoDim = true, nightBrightness = 0.1f)
    assertEquals(0.1f, effectiveBrightness(settings, nightActive = true)!!, 0.0001f)
  }

  @Test
  fun `night level is ignored when auto dim is off`() {
    val settings = AppSettings(
      brightnessMode = BrightnessMode.CUSTOM,
      screenBrightness = 0.6f,
      nightAutoDim = false,
      nightBrightness = 0.1f,
    )
    assertEquals(0.6f, effectiveBrightness(settings, nightActive = true)!!, 0.0001f)
  }

  @Test
  fun `stored levels are clamped into the usable range`() {
    val settings = AppSettings(brightnessMode = BrightnessMode.CUSTOM, screenBrightness = 0f)
    assertEquals(MIN_BRIGHTNESS, effectiveBrightness(settings, nightActive = false)!!, 0.0001f)
  }

  @Test
  fun `night override is active only while dimming is on`() {
    assertTrue(nightBrightnessActive(AppSettings(nightAutoDim = true), nightActive = true))
    assertFalse(nightBrightnessActive(AppSettings(nightAutoDim = false), nightActive = true))
    assertFalse(nightBrightnessActive(AppSettings(nightAutoDim = true), nightActive = false))
  }

  @Test
  fun `dragging up brightens and dragging down dims`() {
    assertEquals(0.599f, brightnessAfterDrag(0.5f, -100f, 1000f), 0.002f)
    assertEquals(0.401f, brightnessAfterDrag(0.5f, 100f, 1000f), 0.002f)
  }

  @Test
  fun `a full height drag covers the whole range`() {
    assertEquals(MAX_BRIGHTNESS, brightnessAfterDrag(0.5f, -1000f, 1000f), 0.0001f)
    assertEquals(MIN_BRIGHTNESS, brightnessAfterDrag(0.5f, 1000f, 1000f), 0.0001f)
  }

  @Test
  fun `a drag without height leaves the level alone`() {
    assertEquals(0.5f, brightnessAfterDrag(0.5f, -100f, 0f), 0.0001f)
  }

  @Test
  fun `percent rounds and clamps`() {
    assertEquals(50, brightnessPercent(0.5f))
    assertEquals(1, brightnessPercent(0f))
    assertEquals(100, brightnessPercent(1f))
  }

  @Test
  fun `gesture starts from the live system level while following it`() {
    val settings = AppSettings(brightnessMode = BrightnessMode.FOLLOW_SYSTEM, screenBrightness = 0.3f)
    assertEquals(
      0.8f,
      gestureStartBrightness(settings, nightActive = false, systemBrightness = 0.8f),
      0.0001f,
    )
  }

  @Test
  fun `gesture falls back to the stored level without a system reading`() {
    val settings = AppSettings(brightnessMode = BrightnessMode.FOLLOW_SYSTEM, screenBrightness = 0.3f)
    assertEquals(
      0.3f,
      gestureStartBrightness(settings, nightActive = false, systemBrightness = null),
      0.0001f,
    )
  }

  @Test
  fun `gesture keeps custom and night levels`() {
    val custom = AppSettings(brightnessMode = BrightnessMode.CUSTOM, screenBrightness = 0.45f)
    assertEquals(
      0.45f,
      gestureStartBrightness(custom, nightActive = false, systemBrightness = 0.9f),
      0.0001f,
    )

    val night = AppSettings(nightAutoDim = true, nightBrightness = 0.15f)
    assertEquals(
      0.15f,
      gestureStartBrightness(night, nightActive = true, systemBrightness = 0.9f),
      0.0001f,
    )
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
    assertEquals(31, cells.count { it != null })
  }
}
