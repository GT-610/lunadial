package com.gt610.lunadial.model

import kotlin.math.roundToInt

/** Lowest brightness LunaDial applies, so the display never becomes unreadable. */
const val MIN_BRIGHTNESS: Float = 0.01f

/** Highest brightness LunaDial applies. */
const val MAX_BRIGHTNESS: Float = 1f

/**
 * The window brightness the clock screen should use, or null to follow the
 * system. The night level wins over the daytime choice, the same way the night
 * presentation replaces the daytime colours.
 */
fun effectiveBrightness(settings: AppSettings, nightActive: Boolean): Float? = when {
  nightBrightnessActive(settings, nightActive) -> settings.nightBrightness.toBrightnessLevel()
  settings.brightnessMode == BrightnessMode.CUSTOM -> settings.screenBrightness.toBrightnessLevel()
  else -> null
}

/** True when the night level is what controls the screen right now. */
fun nightBrightnessActive(settings: AppSettings, nightActive: Boolean): Boolean =
  nightActive && settings.nightAutoDim

/** A 0..100 value for labels such as "50%". */
fun brightnessPercent(brightness: Float): Int =
  (brightness.coerceIn(MIN_BRIGHTNESS, MAX_BRIGHTNESS) * 100f).roundToInt()

/**
 * Brightness after dragging [dragY] pixels: the screen height spans the whole
 * range, and dragging up (negative [dragY]) brightens.
 */
fun brightnessAfterDrag(start: Float, dragY: Float, screenHeightPx: Float): Float {
  if (screenHeightPx <= 0f) return start.toBrightnessLevel()
  val delta = -dragY / screenHeightPx * (MAX_BRIGHTNESS - MIN_BRIGHTNESS)
  return (start + delta).toBrightnessLevel()
}

/** Clamps a value that may come from old preferences into the usable range. */
fun Float.toBrightnessLevel(): Float = coerceIn(MIN_BRIGHTNESS, MAX_BRIGHTNESS)