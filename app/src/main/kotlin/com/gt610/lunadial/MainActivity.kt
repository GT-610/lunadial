package com.gt610.lunadial

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    enableEdgeToEdge()
    super.onCreate(savedInstanceState)
    val settingsStore = (application as LunaDialApplication).settingsStore
    setContent {
      LunaDialApp(settingsStore = settingsStore)
    }
  }
}
