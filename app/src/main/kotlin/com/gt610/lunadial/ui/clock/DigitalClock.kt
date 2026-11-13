package com.gt610.lunadial.ui.clock

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gt610.lunadial.R
import com.gt610.lunadial.model.AppSettings
import com.gt610.lunadial.util.clockPattern
import com.gt610.lunadial.util.formatWithPattern
import com.gt610.lunadial.util.resolveUse24Hour
import java.util.Calendar
import com.gt610.lunadial.util.rememberLocale

/**
 * The digital face: date above, time below, both scaled down to fit the width
 * the same way the Flutter version's FittedBox did.
 */
@Composable
fun DigitalClock(
  now: Calendar,
  settings: AppSettings,
  nightMode: Boolean,
  modifier: Modifier = Modifier,
) {
  val context = LocalContext.current
  val locale = rememberLocale()
  val use24Hour = remember(context, settings.timeFormat) {
    resolveUse24Hour(context, settings.timeFormat)
  }
  val timePattern = remember(locale, use24Hour, settings.showSeconds, settings.leadingZero) {
    clockPattern(locale, use24Hour, settings.showSeconds, settings.leadingZero)
  }
  val datePattern = stringResource(R.string.date_format)

  val timeText = remember(now.timeInMillis, timePattern, locale) {
    formatWithPattern(now.time, timePattern, locale)
  }
  val dateText = remember(now.timeInMillis, datePattern, locale) {
    formatWithPattern(now.time, datePattern, locale)
  }

  val semanticsLabel = stringResource(R.string.digital_clock_semantics)
  val colors = MaterialTheme.colorScheme
  val timeColor = if (nightMode) colors.onSurface.copy(alpha = 0.92f) else colors.onSurface
  val dateColor = if (nightMode) colors.onSurface.copy(alpha = 0.42f) else colors.onSurface

  BoxWithConstraints(
    modifier = modifier
      .fillMaxSize()
      .semantics { contentDescription = semanticsLabel },
    contentAlignment = Alignment.Center,
  ) {
    val isLandscape = maxWidth >= maxHeight
    val metrics = digitalMetrics(maxWidth, maxHeight)
    val timeStyle = TextStyle(
      fontSize = (metrics.timeFontSize * nightTimeScale(nightMode, isLandscape)).sp,
      fontWeight = if (nightMode) FontWeight.Light else FontWeight.Normal,
      letterSpacing = if (nightMode && isLandscape) 2.4.sp else 0.sp,
      color = timeColor,
      fontFeatureSettings = "tnum",
    )
    val dateStyle = TextStyle(
      fontSize = (
        metrics.dateFontSize *
          if (nightMode && isLandscape) 0.9f else 1f
        ).sp,
      fontWeight = FontWeight.Normal,
      color = dateColor,
    )
    val spacing = metrics.spacing * nightSpacingScale(nightMode, isLandscape)
    val contentWidth = maxWidth - metrics.paddingHorizontal * 2

    Column(
      modifier = Modifier.padding(
        horizontal = metrics.paddingHorizontal,
        vertical = metrics.paddingVertical,
      ),
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalArrangement = Arrangement.Center,
    ) {
      ShrinkToFitText(
        text = dateText,
        style = dateStyle,
        maxWidth = contentWidth,
        modifier = Modifier,
      )
      Column(Modifier.padding(top = spacing)) {
        ShrinkToFitText(
          text = timeText,
          style = timeStyle,
          maxWidth = contentWidth,
        )
      }
    }
  }
}

private fun nightTimeScale(nightMode: Boolean, isLandscape: Boolean): Float = when {
  !nightMode -> 1f
  isLandscape -> 1.12f
  else -> 1.04f
}

private fun nightSpacingScale(nightMode: Boolean, isLandscape: Boolean): Float = when {
  !nightMode -> 1f
  isLandscape -> 0.78f
  else -> 0.92f
}

private data class DigitalMetrics(
  val timeFontSize: Float,
  val dateFontSize: Float,
  val spacing: Dp,
  val paddingHorizontal: Dp,
  val paddingVertical: Dp,
)

private fun digitalMetrics(width: Dp, height: Dp): DigitalMetrics {
  val shortest = minOf(width.value, height.value)
  return when {
    shortest < 360f -> DigitalMetrics(
      timeFontSize = (shortest * 0.31f).coerceIn(40f, 82f),
      dateFontSize = (shortest * 0.31f * 0.3f).coerceIn(14f, 24f),
      spacing = 8.dp,
      paddingHorizontal = 12.dp,
      paddingVertical = 20.dp,
    )
    shortest < 480f -> DigitalMetrics(
      timeFontSize = (shortest * 0.34f).coerceIn(56f, 110f),
      dateFontSize = (shortest * 0.34f * 0.3f).coerceIn(18f, 34f),
      spacing = 10.dp,
      paddingHorizontal = 16.dp,
      paddingVertical = 24.dp,
    )
    shortest < 600f -> DigitalMetrics(
      timeFontSize = (shortest * 0.4f).coerceIn(72f, 230f),
      dateFontSize = (shortest * 0.4f * 0.28f).coerceIn(22f, 52f),
      spacing = 12.dp,
      paddingHorizontal = 16.dp,
      paddingVertical = 28.dp,
    )
    shortest < 900f -> DigitalMetrics(
      timeFontSize = (shortest * 0.4f).coerceIn(112f, 230f),
      dateFontSize = (shortest * 0.4f * 0.26f).coerceIn(28f, 52f),
      spacing = 16.dp,
      paddingHorizontal = 16.dp,
      paddingVertical = 32.dp,
    )
    else -> DigitalMetrics(
      timeFontSize = (height.value * 0.3f).coerceIn(132f, 260f),
      dateFontSize = (height.value * 0.3f * 0.25f).coerceIn(32f, 60f),
      spacing = 18.dp,
      paddingHorizontal = 20.dp,
      paddingVertical = 40.dp,
    )
  }
}

/**
 * Draws [text] at [style], scaling the font size down when the measured width
 * would exceed [maxWidth]. Glyph advances scale linearly with the font size, so
 * a single measurement is enough.
 */
@Composable
private fun ShrinkToFitText(
  text: String,
  style: TextStyle,
  maxWidth: Dp,
  modifier: Modifier = Modifier,
) {
  val measurer = rememberTextMeasurer()
  val density = LocalDensity.current
  val availablePx = with(density) { maxWidth.roundToPx() }
  val fittedStyle = remember(text, style, availablePx) {
    if (availablePx <= 0) {
      style
    } else {
      val measured = measurer.measure(
        text = text,
        style = style,
        maxLines = 1,
        softWrap = false,
      ).size.width
      if (measured == 0 || measured <= availablePx) {
        style
      } else {
        val scale = availablePx.toFloat() / measured
        style.copy(fontSize = (style.fontSize.value * scale).sp)
      }
    }
  }
  Text(
    text = text,
    style = fittedStyle,
    maxLines = 1,
    softWrap = false,
    textAlign = TextAlign.Center,
    modifier = modifier,
  )
}
