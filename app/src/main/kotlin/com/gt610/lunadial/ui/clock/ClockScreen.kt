package com.gt610.lunadial.ui.clock

import android.app.Activity
import android.view.WindowManager
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.Crossfade
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBars
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.repeatOnLifecycle
import com.gt610.lunadial.R
import com.gt610.lunadial.data.isWithinNightWindow
import com.gt610.lunadial.model.AppSettings
import com.gt610.lunadial.model.ClockDisplayMode
import com.gt610.lunadial.model.NightModeBehavior
import com.gt610.lunadial.util.minutesOfDay
import kotlinx.coroutines.delay
import java.util.Calendar

private const val CONTROLS_VISIBLE_MILLIS = 5_000L

/** The home screen: clock face, optional calendar, and auto-hiding controls. */
@Composable
fun ClockScreen(
  settings: AppSettings,
  onOpenSettings: () -> Unit,
  modifier: Modifier = Modifier,
) {
  val now = rememberTickingNow()
  val systemDark = isSystemInDarkTheme()
  val nightActive = remember(
    settings.nightMode,
    settings.nightStartMinutes,
    settings.nightEndMinutes,
    now.timeInMillis,
    systemDark,
  ) {
    when (settings.nightMode) {
      NightModeBehavior.OFF -> false
      NightModeBehavior.ON -> true
      NightModeBehavior.FOLLOW_SYSTEM -> systemDark
      NightModeBehavior.SCHEDULED -> isWithinNightWindow(
        minutesOfDay = minutesOfDay(now),
        startMinutes = settings.nightStartMinutes,
        endMinutes = settings.nightEndMinutes,
      )
    }
  }

  var controlsVisible by remember { mutableStateOf(true) }
  LaunchedEffect(controlsVisible) {
    if (controlsVisible) {
      delay(CONTROLS_VISIBLE_MILLIS)
      controlsVisible = false
    }
  }

  HideSystemBars()
  KeepScreenOn(enabled = settings.keepScreenOn)

  val background = if (nightActive) Color.Black else MaterialTheme.colorScheme.background

  Box(
    modifier = modifier
      .fillMaxSize()
      .background(background),
  ) {
    // Bottom-most layer: the clock itself is not interactive, so taps fall
    // through to here. A tap only reveals or hides the controls; opening
    // settings stays the gear button's job, as in any Android app.
    Box(
      modifier = Modifier
        .matchParentSize()
        .clickable(
          interactionSource = remember { MutableInteractionSource() },
          indication = null,
        ) { controlsVisible = !controlsVisible },
    )

    BurnInProtection(
      enabled = nightActive && settings.burnInProtection,
      modifier = Modifier.fillMaxSize(),
    ) {
      ClockContent(
        now = now,
        settings = settings,
        nightActive = nightActive,
      )
    }

    AnimatedVisibility(
      visible = controlsVisible,
      enter = fadeIn(),
      exit = fadeOut(),
      modifier = Modifier
        .align(Alignment.TopCenter)
        .fillMaxWidth()
        .padding(WindowInsets.systemBars.asPaddingValues())
        .padding(horizontal = 20.dp, vertical = 12.dp),
    ) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
      ) {
        Text(
          text = stringResource(R.string.app_name),
          style = MaterialTheme.typography.titleMedium,
          fontWeight = FontWeight.Medium,
          color = if (nightActive) Color.White.copy(alpha = 0.7f) else MaterialTheme.colorScheme.onSurface,
        )
        IconButton(onClick = onOpenSettings) {
          Icon(
            imageVector = Icons.Filled.Settings,
            contentDescription = stringResource(R.string.open_settings),
            tint = if (nightActive) Color.White.copy(alpha = 0.7f) else MaterialTheme.colorScheme.onSurface,
          )
        }
      }
    }
  }
}

@Composable
private fun ClockContent(
  now: Calendar,
  settings: AppSettings,
  nightActive: Boolean,
) {
  Crossfade(targetState = settings.clockDisplayMode, label = "clock-face") { mode ->
    when (mode) {
      ClockDisplayMode.DIGITAL -> DigitalClock(
        now = now,
        settings = settings,
        nightMode = nightActive,
        modifier = Modifier.fillMaxSize(),
      )
      ClockDisplayMode.ANALOG -> AnalogClockWithCalendar(
        now = now,
        settings = settings,
        nightActive = nightActive,
      )
    }
  }
}

@Composable
private fun AnalogClockWithCalendar(
  now: Calendar,
  settings: AppSettings,
  nightActive: Boolean,
) {
  var focusedMonth by remember {
    mutableStateOf(
      (now.clone() as Calendar).apply {
        set(Calendar.DAY_OF_MONTH, 1)
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
      },
    )
  }
  var selectedDay by remember { mutableStateOf<Calendar?>(null) }
  val semanticsLabel = stringResource(R.string.analog_clock_semantics)

  BoxWithConstraints(
    Modifier
      .fillMaxSize()
      .semantics { contentDescription = semanticsLabel }
      // Leave the top strip free for the auto-hiding title bar.
      .padding(start = 24.dp, end = 24.dp, top = 72.dp, bottom = 24.dp),
  ) {
    val availableWidth = maxWidth
    val availableHeight = maxHeight
    val isLandscape = availableWidth >= availableHeight
    val monthChanger: (Int) -> Unit = { delta ->
      focusedMonth = (focusedMonth.clone() as Calendar).apply { add(Calendar.MONTH, delta) }
    }
    val daySelector: (Int) -> Unit = { day ->
      selectedDay = (focusedMonth.clone() as Calendar).apply { set(Calendar.DAY_OF_MONTH, day) }
    }

    if (isLandscape) {
      // The calendar is roughly 1.45x as tall as it is wide, so cap its width by
      // the available height to keep every row on screen.
      val calendarWidth = minOf(availableWidth * 0.46f, availableHeight * 0.68f)
      Row(
        modifier = Modifier.fillMaxSize(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(24.dp),
      ) {
        AnalogClock(
          now = now,
          showSecondHand = settings.showSeconds,
          nightMode = nightActive,
          modifier = Modifier.size(minOf(availableHeight, availableWidth * 0.45f)),
        )
        Box(Modifier.weight(1f), contentAlignment = Alignment.Center) {
          CalendarPanel(
            focusedMonth = focusedMonth,
            selectedDay = selectedDay,
            today = now,
            nightMode = nightActive,
            onMonthChange = monthChanger,
            onDaySelected = daySelector,
            modifier = Modifier.width(calendarWidth),
          )
        }
      }
    } else {
      val clockSize = minOf(availableWidth, availableHeight * 0.52f)
      val calendarWidth = minOf(availableWidth, availableHeight * 0.33f)
      Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
      ) {
        AnalogClock(
          now = now,
          showSecondHand = settings.showSeconds,
          nightMode = nightActive,
          modifier = Modifier.size(clockSize),
        )
        Column(Modifier.padding(top = 20.dp)) {
          CalendarPanel(
            focusedMonth = focusedMonth,
            selectedDay = selectedDay,
            today = now,
            nightMode = nightActive,
            onMonthChange = monthChanger,
            onDaySelected = daySelector,
            modifier = Modifier.width(calendarWidth),
          )
        }
      }
    }
  }
}

/**
 * A [Calendar] that advances on every wall-clock second while the screen is
 * resumed, so the seconds hand stays aligned instead of drifting.
 */
@Composable
fun rememberTickingNow(): Calendar {
  var now by remember { mutableStateOf(Calendar.getInstance()) }
  val lifecycleOwner = LocalLifecycleOwner.current
  LaunchedEffect(lifecycleOwner) {
    lifecycleOwner.repeatOnLifecycle(Lifecycle.State.RESUMED) {
      while (true) {
        val current = Calendar.getInstance()
        now = current
        delay(1_000L - current.get(Calendar.MILLISECOND).toLong())
      }
    }
  }
  return now
}

@Composable
private fun HideSystemBars() {
  val view = LocalView.current
  val context = LocalContext.current
  DisposableEffect(Unit) {
    val window = (context as? Activity)?.window ?: return@DisposableEffect onDispose {}
    WindowCompat.setDecorFitsSystemWindows(window, false)
    val controller = WindowInsetsControllerCompat(window, view)
    controller.hide(WindowInsetsCompat.Type.systemBars())
    controller.systemBarsBehavior =
      WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
    onDispose {
      controller.show(WindowInsetsCompat.Type.systemBars())
    }
  }
}

@Composable
private fun KeepScreenOn(enabled: Boolean) {
  val context = LocalContext.current
  DisposableEffect(enabled) {
    val window = (context as? Activity)?.window
    if (window != null && enabled) {
      window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
    onDispose {
      if (window != null) {
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
      }
    }
  }
}
