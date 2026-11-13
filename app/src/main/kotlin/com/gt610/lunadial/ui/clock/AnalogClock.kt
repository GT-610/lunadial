package com.gt610.lunadial.ui.clock

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.sp
import java.util.Calendar
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin

/**
 * Analog face in the style of a bedside / standby clock: no dial outline, a
 * ring of minute ticks, twelve numerals, thick hour and minute hands and a thin
 * accent-coloured second hand with a filled pivot.
 */
@Composable
fun AnalogClock(
  now: Calendar,
  showSecondHand: Boolean,
  nightMode: Boolean,
  modifier: Modifier = Modifier,
) {
  val colors = MaterialTheme.colorScheme
  val handColor = if (nightMode) Color.White else colors.onSurface
  val tickColor = handColor.copy(alpha = if (nightMode) 0.45f else 0.38f)
  val numeralColor = handColor
  val accent = if (nightMode) colors.primary else colors.primary
  val measurer = rememberTextMeasurer()

  val hours = now.get(Calendar.HOUR)
  val minutes = now.get(Calendar.MINUTE)
  val seconds = now.get(Calendar.SECOND)

  Canvas(modifier = modifier.fillMaxSize().aspectRatio(1f)) {
    val radius = min(size.width, size.height) / 2f
    val center = Offset(size.width / 2f, size.height / 2f)

    drawTickRing(center = center, radius = radius, color = tickColor)
    drawNumerals(
      center = center,
      radius = radius,
      color = numeralColor,
      measurer = measurer,
    )

    val hourAngle = (hours % 12 + minutes / 60f) * 30f - 90f
    val minuteAngle = (minutes + seconds / 60f) * 6f - 90f

    drawHand(
      center = center,
      length = radius * 0.46f,
      angleDegrees = hourAngle,
      color = handColor,
      strokeWidth = radius * 0.055f,
    )
    drawHand(
      center = center,
      length = radius * 0.70f,
      angleDegrees = minuteAngle,
      color = handColor,
      strokeWidth = radius * 0.048f,
    )

    if (showSecondHand) {
      val secondAngle = seconds * 6f - 90f
      drawSecondHand(
        center = center,
        radius = radius,
        angleDegrees = secondAngle,
        color = accent,
      )
    }

    // Small filled pivot in the accent colour, like a bedside clock.
    drawCircle(color = accent, radius = radius * 0.026f, center = center)
  }
}

/** 60 dashes just inside the dial edge, longer and brighter on every 5th. */
private fun DrawScope.drawTickRing(center: Offset, radius: Float, color: Color) {
  repeat(60) { index ->
    val angle = Math.toRadians((index * 6 - 90).toDouble())
    val isMajor = index % 5 == 0
    val outer = radius * 0.98f
    val length = radius * if (isMajor) 0.070f else 0.038f
    val inner = outer - length
    val start = Offset(
      x = center.x + (cos(angle) * outer).toFloat(),
      y = center.y + (sin(angle) * outer).toFloat(),
    )
    val end = Offset(
      x = center.x + (cos(angle) * inner).toFloat(),
      y = center.y + (sin(angle) * inner).toFloat(),
    )
    drawLine(
      color = if (isMajor) color else color.copy(alpha = color.alpha * 0.75f),
      start = start,
      end = end,
      strokeWidth = radius * if (isMajor) 0.014f else 0.009f,
      cap = StrokeCap.Round,
    )
  }
}

private fun DrawScope.drawNumerals(
  center: Offset,
  radius: Float,
  color: Color,
  measurer: TextMeasurer,
) {
  // Size in pixels, then convert to sp so density and font scale do not
  // inflate the numerals past the tick ring.
  val fontSizeSp = (radius * 0.19f) / density / fontScale
  val style = TextStyle(
    fontSize = fontSizeSp.sp,
    color = color,
    fontWeight = FontWeight.Light,
  )
  for (hour in 1..12) {
    val angle = Math.toRadians((hour * 30 - 90).toDouble())
    val distance = radius * 0.755f
    val layout = measurer.measure(hour.toString(), style)
    val position = Offset(
      x = center.x + (cos(angle) * distance).toFloat() - layout.size.width / 2f,
      y = center.y + (sin(angle) * distance).toFloat() - layout.size.height / 2f,
    )
    drawText(textLayoutResult = layout, topLeft = position)
  }
}

private fun DrawScope.drawHand(
  center: Offset,
  length: Float,
  angleDegrees: Float,
  color: Color,
  strokeWidth: Float,
) {
  val angle = Math.toRadians(angleDegrees.toDouble())
  val end = Offset(
    x = center.x + (cos(angle) * length).toFloat(),
    y = center.y + (sin(angle) * length).toFloat(),
  )
  val tail = Offset(
    x = center.x - (cos(angle) * length * 0.16f).toFloat(),
    y = center.y - (sin(angle) * length * 0.16f).toFloat(),
  )
  drawLine(
    color = color,
    start = tail,
    end = end,
    strokeWidth = strokeWidth,
    cap = StrokeCap.Round,
  )
}

private fun DrawScope.drawSecondHand(
  center: Offset,
  radius: Float,
  angleDegrees: Float,
  color: Color,
) {
  val angle = Math.toRadians(angleDegrees.toDouble())
  val end = Offset(
    x = center.x + (cos(angle) * radius * 0.82f).toFloat(),
    y = center.y + (sin(angle) * radius * 0.82f).toFloat(),
  )
  val tail = Offset(
    x = center.x - (cos(angle) * radius * 0.12f).toFloat(),
    y = center.y - (sin(angle) * radius * 0.12f).toFloat(),
  )
  drawLine(
    color = color,
    start = tail,
    end = end,
    strokeWidth = radius * 0.011f,
    cap = StrokeCap.Round,
  )
}
