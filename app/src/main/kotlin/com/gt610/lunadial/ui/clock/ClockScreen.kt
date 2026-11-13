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
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.calculateEndPadding
import androidx.compose.foundation.layout.calculateStartPadding
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
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
import androidx.compose.ui.platform.LocalLayoutDirection
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
private val CONTROLS_BAR_HEIGHT = 56.dp
private val CONTENT_MARGIN = 16.dp

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

  // Respect display cutouts as well as the system bars: in landscape the punch
  // hole sits on the short edge and would otherwise eat into the dial.
  val layoutDirection = LocalLayoutDirection.current
  val safeInsets = WindowInsets.safeDrawing.asPaddingValues()
  val contentPadding = PaddingValues(
    start = safeInsets.calculateStartPadding(layoutDirection) + CONTENT_MARGIN,
    end = safeInsets.calculateEndPadding(layoutDirection) + CONTENT_MARGIN,
    top = safeInsets.calculateTopPadding() + CONTROLS_BAR_HEIGHT + CONTENT_MARGIN,
    bottom = safeInsets.calculateBottomPadding() + CONTENT_MARGIN,
  )

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

    // The night presentation is a dark surface no matter what the app theme
    // is, so the clock content gets its own dark scheme. Reusing the light
    // scheme here would paint near-black text on a black background.
    val clockScheme = if (nightActive) {
      darkColorScheme(
        primary = MaterialTheme.colorScheme.primary,
        secondary = MaterialTheme.colorScheme.secondary,
        tertiary = MaterialTheme.colorScheme.tertiary,
      )
    } else {
      MaterialTheme.colorScheme
    }

    MaterialTheme(colorScheme = clockScheme) {
      BurnInProtection(
        enabled = nightActive && settings.burnInProtection,
        modifier = Modifier
          .fillMaxSize()
          .padding(contentPadding),
      ) {
        ClockContent(
          now = now,
          settings = settings,
          nightActive = nightActive,
        )
      }
    }

    AnimatedVisibility(
      visible = controlsVisible,
      enter = fadeIn(),
      exit = fadeOut(),
      modifier = Modifier
        .align(Alignment.TopCenter)
        .fillMaxWidth()
        .padding(safeInsets)
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
      .semantics { contentDescription = semanticsLabel },
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
      // Clock and calendar are laid out as one centred pair, sized from the
      // shorter side so neither runs into the cutout or the edges.
      val gap = 32.dp
      val usableWidth = availableWidth - gap
      val clockSize = minOf(availableHeight * 0.92f, usableWidth * 0.62f)
      val calendarWidth = minOf(usableWidth * 0.38f, availableHeight * 0.75f)
      Row(
        modifier = Modifier.fillMaxSize(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center,
      ) {
        AnalogClock(
          now = now,
          showSecondHand = settings.showSeconds,
          nightMode = nightActive,
          modifier = Modifier.size(clockSize),
        )
        Spacer(Modifier.width(gap))
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
    } else {
      val gap = 20.dp
      val clockSize = minOf(availableWidth, availableHeight * 0.52f)
      val calendarWidth = minOf(availableWidth, availableHeight * 0.32f)
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
        Spacer(Modifier.height(gap))
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
