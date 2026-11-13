package com.gt610.lunadial

import android.app.Application
import com.gt610.lunadial.data.SettingsStore

class LunaDialApplication : Application() {
  /** Created once so that every activity and composable sees the same state. */
  val settingsStore: SettingsStore by lazy { SettingsStore(this) }
}
