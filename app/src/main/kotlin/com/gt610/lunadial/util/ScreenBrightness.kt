package com.gt610.lunadial.util

import android.app.Activity
import android.view.WindowManager
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.ui.platform.LocalContext

/**
 * Overrides the brightness of this app's window only. The device setting is
 * never touched, so no permission is needed, and the override ends with the
 * composition. A null [brightness] follows the system again.
 */
@Composable
fun ScreenBrightnessOverride(brightness: Float?) {
  val context = LocalContext.current
  DisposableEffect(brightness) {
    val window = (context as? Activity)?.window
    if (window == null) return@DisposableEffect onDispose {}

    val params = window.attributes
    params.screenBrightness =
      brightness ?: WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
    window.attributes = params

    onDispose {
      val reset = window.attributes
      reset.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
      window.attributes = reset
    }
  }
}