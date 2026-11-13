package com.gt610.lunadial.util

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalConfiguration
import java.util.Locale

/**
 * The active locale, read in a way Compose can observe. Calling
 * [Locale.getDefault] directly in a composable would not recompose when the
 * user switches the app language.
 */
@Composable
fun rememberLocale(): Locale {
  val configuration = LocalConfiguration.current
  return remember(configuration) { configuration.locales[0] }
}
