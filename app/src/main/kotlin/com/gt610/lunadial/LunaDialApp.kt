package com.gt610.lunadial

import androidx.activity.compose.BackHandler
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.core.os.LocaleListCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.gt610.lunadial.data.SettingsStore
import com.gt610.lunadial.model.AppSettings
import com.gt610.lunadial.ui.clock.ClockScreen
import com.gt610.lunadial.ui.settings.SettingsScreen
import com.gt610.lunadial.ui.theme.LunaDialTheme

@Composable
fun LunaDialApp(settingsStore: SettingsStore) {
  val settings by settingsStore.settings.collectAsStateWithLifecycle()
  var showSettings by rememberSaveable { mutableStateOf(false) }

  ApplyLanguage(settings)

  LunaDialTheme(settings = settings) {
    Surface(
      modifier = Modifier.fillMaxSize(),
      color = MaterialTheme.colorScheme.background,
    ) {
      if (showSettings) {
        BackHandler { showSettings = false }
        SettingsScreen(
          settings = settings,
          onUpdate = settingsStore::update,
          onBack = { showSettings = false },
        )
      } else {
        ClockScreen(
          settings = settings,
          onOpenSettings = { showSettings = true },
        )
      }
    }
  }
}

/**
 * Keeps the per-app language in sync with the stored preference. AppCompat
 * recreates the activity when the locales actually change, so the comparison
 * also guards against a recreate loop on startup.
 */
@Composable
private fun ApplyLanguage(settings: AppSettings) {
  val tag = settings.locale.languageTag
  LaunchedEffect(tag) {
    val desired = if (tag == null) {
      LocaleListCompat.getEmptyLocaleList()
    } else {
      LocaleListCompat.forLanguageTags(tag)
    }
    val current = AppCompatDelegate.getApplicationLocales()
    if (current != desired) {
      AppCompatDelegate.setApplicationLocales(desired)
    }
  }
}
