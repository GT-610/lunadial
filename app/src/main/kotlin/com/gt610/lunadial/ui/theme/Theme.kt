package com.gt610.lunadial.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.platform.LocalContext
import com.gt610.lunadial.model.AppSettings
import com.gt610.lunadial.model.ThemeModeOption

@Composable
fun LunaDialTheme(settings: AppSettings, content: @Composable () -> Unit) {
  val context = LocalContext.current
  val systemDark = isSystemInDarkTheme()
  val dark = when (settings.themeMode) {
    ThemeModeOption.SYSTEM -> systemDark
    ThemeModeOption.LIGHT -> false
    ThemeModeOption.DARK, ThemeModeOption.OLED -> true
  }

  val supportsDynamicColor = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
  val base = when {
    settings.useDynamicColor && supportsDynamicColor ->
      if (dark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    else -> schemeFromSeed(seed = Color(settings.themeColor), dark = dark)
  }

  val scheme = if (settings.themeMode == ThemeModeOption.OLED) base.asOled() else base

  MaterialTheme(colorScheme = scheme, content = content)
}

/**
 * Small tonal approximation of Material You: the accent is pushed towards the
 * light or dark end of the scale so that it keeps enough contrast on the
 * neutral surfaces Material 3 provides by default.
 */
private fun schemeFromSeed(seed: Color, dark: Boolean): ColorScheme {
  val black = Color.Black
  val white = Color.White
  return if (dark) {
    val primary = lerp(seed, white, 0.35f)
    val container = lerp(seed, black, 0.45f)
    darkColorScheme(
      primary = primary,
      onPrimary = lerp(seed, black, 0.80f),
      primaryContainer = container,
      onPrimaryContainer = lerp(seed, white, 0.80f),
      secondary = lerp(seed, white, 0.55f),
      secondaryContainer = lerp(seed, black, 0.55f),
      tertiary = lerp(seed, white, 0.45f),
    )
  } else {
    val primary = lerp(seed, black, 0.35f)
    val container = lerp(seed, white, 0.75f)
    lightColorScheme(
      primary = primary,
      onPrimary = white,
      primaryContainer = container,
      onPrimaryContainer = lerp(seed, black, 0.65f),
      secondary = lerp(seed, black, 0.45f),
      secondaryContainer = lerp(seed, white, 0.70f),
      tertiary = lerp(seed, black, 0.55f),
    )
  }
}

/** Pure-black surfaces for OLED panels; keeps the accent and on-colours. */
private fun ColorScheme.asOled(): ColorScheme {
  val black = Color.Black
  return copy(
    background = black,
    surface = black,
    surfaceVariant = lerp(surfaceVariant, black, 0.55f),
    surfaceContainerLowest = black,
    surfaceContainerLow = black,
    surfaceContainer = black,
    surfaceContainerHigh = lerp(surfaceContainerHigh, black, 0.75f),
    surfaceContainerHighest = lerp(surfaceContainerHighest, black, 0.75f),
    surfaceDim = black,
    surfaceBright = lerp(surfaceBright, black, 0.75f),
  )
}

/**
 * Scheme for the clock content. The night presentation is always dark, even
 * when the app itself is in a light theme, so it gets a dark scheme that keeps
 * the accent.
 */
fun clockColorScheme(base: ColorScheme, night: Boolean): ColorScheme =
  if (night) {
    darkColorScheme(
      primary = base.primary,
      secondary = base.secondary,
      tertiary = base.tertiary,
    )
  } else {
    base
  }
