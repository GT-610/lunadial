package com.gt610.lunadial.ui.clock

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.util.Calendar
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin

/**
 * Analog face drawn straight onto a Canvas: outline, 60 ticks with longer
 * five-minute marks, hour numerals, and hour/minute/second hands.
 */
@Composable
fun AnalogClock(
  now: Calendar,
  showSecondHand: Boolean,
  nightMode: Boolean,
  modifier: Modifier = Modifier,
) {
  val colors = MaterialTheme.colorScheme
  val dialColor = if (nightMode) {
    colors.onSurface.copy(alpha = 0.55f)
  } else {
    colors.onSurface.copy(alpha = 0.72f)
  }
  val handColor = if (nightMode) colors.onSurface.copy(alpha = 0.92f) else colors.onSurface
  val secondColor = if (nightMode) {
    colors.onSurface.copy(alpha = 0.65f)
  } else {
    colors.primary
  }
  val measurer = rememberTextMeasurer()

  val hours = now.get(Calendar.HOUR)
  val minutes = now.get(Calendar.MINUTE)
  val seconds = now.get(Calendar.SECOND)

  Canvas(modifier = modifier.fillMaxSize().aspectRatio(1f)) {
    val radius = min(size.width, size.height) / 2f
    val center = Offset(size.width / 2f, size.height / 2f)
    val unit = radius / 100f

    drawCircle(
      color = dialColor.copy(alpha = 0.35f),
      radius = radius - unit,
      center = center,
      style = Stroke(width = unit * 1.2f),
    )

    drawTicks(center = center, radius = radius, unit = unit, color = dialColor)
    drawNumerals(
      center = center,
      radius = radius,
      unit = unit,
      color = handColor,
      measurer = measurer,
      nightMode = nightMode,
    )

    val hourAngle = (hours % 12 + minutes / 60f) * 30f - 90f
    val minuteAngle = (minutes + seconds / 60f) * 6f - 90f
    drawHand(center, radius * 0.5f, hourAngle, handColor, unit * 4.2f)
    drawHand(center, radius * 0.74f, minuteAngle, handColor, unit * 3f)

    if (showSecondHand) {
      val secondAngle = seconds * 6f - 90f
      drawHand(center, radius * 0.84f, secondAngle, secondColor, unit * 1.1f)
    }

    drawCircle(color = handColor, radius = unit * 4.2f, center = center)
    drawCircle(color = dialColor, radius = unit * 1.8f, center = center)
  }
}

private fun DrawScope.drawTicks(
  center: Offset,
  radius: Float,
  unit: Float,
  color: Color,
) {
  repeat(60) { index ->
    val angle = Math.toRadians((index * 6 - 90).toDouble())
    val isMajor = index % 5 == 0
    val outer = radius - unit * 2.5f
    val inner = outer - if (isMajor) unit * 6.5f else unit * 3f
    val start = Offset(
      x = center.x + (cos(angle) * outer).toFloat(),
      y = center.y + (sin(angle) * outer).toFloat(),
    )
    val end = Offset(
      x = center.x + (cos(angle) * inner).toFloat(),
      y = center.y + (sin(angle) * inner).toFloat(),
    )
    drawLine(
      color = if (isMajor) color else color.copy(alpha = color.alpha * 0.6f),
      start = start,
      end = end,
      strokeWidth = if (isMajor) unit * 1.8f else unit * 0.9f,
      cap = StrokeCap.Round,
    )
  }
}

private fun DrawScope.drawNumerals(
  center: Offset,
  radius: Float,
  unit: Float,
  color: Color,
  measurer: TextMeasurer,
  nightMode: Boolean,
) {
  // Size the numerals in pixels, then convert back to sp so that density and
  // the user's font scale do not blow them up past the tick ring.
  val fontSizeSp = (radius / 12f) / density / fontScale
  val style = TextStyle(
    fontSize = fontSizeSp.sp,
    color = color.copy(alpha = if (nightMode) 0.85f else 0.95f),
    fontWeight = FontWeight.Light,
  )
  for (hour in 1..12) {
    val angle = Math.toRadians((hour * 30 - 90).toDouble())
    val distance = radius * 0.77f
    val text = hour.toString()
    val layout = measurer.measure(text, style)
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
    x = center.x - (cos(angle) * length * 0.12f).toFloat(),
    y = center.y - (sin(angle) * length * 0.12f).toFloat(),
  )
  drawLine(
    color = color,
    start = tail,
    end = end,
    strokeWidth = strokeWidth,
    cap = StrokeCap.Round,
  )
}
