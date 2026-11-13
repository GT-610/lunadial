package com.gt610.lunadial.ui.clock

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gt610.lunadial.R
import com.gt610.lunadial.util.formatWithPattern
import com.gt610.lunadial.util.isSameDay
import com.gt610.lunadial.util.monthCells
import com.gt610.lunadial.util.weekdayLabels
import java.util.Calendar
import com.gt610.lunadial.util.rememberLocale

/**
 * A compact month calendar: month navigation header, weekday labels, and a day
 * grid where today is outlined and the selected day is filled.
 */
@Composable
fun CalendarPanel(
  focusedMonth: Calendar,
  selectedDay: Calendar?,
  today: Calendar,
  nightMode: Boolean,
  onMonthChange: (Int) -> Unit,
  onDaySelected: (Int) -> Unit,
  modifier: Modifier = Modifier,
) {
  val locale = rememberLocale()
  val colors = MaterialTheme.colorScheme
  val textColor = if (nightMode) colors.onSurface.copy(alpha = 0.85f) else colors.onSurface
  val mutedColor = if (nightMode) colors.onSurface.copy(alpha = 0.45f) else colors.onSurfaceVariant

  val headerPattern = stringResource(R.string.calendar_header_format)
  val header = remember(focusedMonth.timeInMillis, headerPattern, locale) {
    formatWithPattern(focusedMonth.time, headerPattern, locale)
  }
  val weekdayLabels = remember(locale) { weekdayLabels(locale) }
  val cells = remember(focusedMonth.timeInMillis) { monthCells(focusedMonth) }

  BoxWithConstraints(modifier = modifier) {
    val cellSize = maxWidth / 7
    val dayFontSize: TextUnit = (cellSize.value * 0.36f).coerceIn(10f, 18f).sp
    val labelFontSize: TextUnit = (cellSize.value * 0.26f).coerceIn(9f, 13f).sp

    Column(modifier = Modifier.fillMaxWidth()) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
      ) {
        IconButton(onClick = { onMonthChange(-1) }) {
          Icon(
            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowLeft,
            contentDescription = stringResource(R.string.previous_month),
            tint = textColor,
          )
        }
        Text(
          text = header,
          color = textColor,
          fontSize = (cellSize.value * 0.34f).coerceIn(13f, 20f).sp,
          fontWeight = FontWeight.Medium,
        )
        IconButton(onClick = { onMonthChange(1) }) {
          Icon(
            imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
            contentDescription = stringResource(R.string.next_month),
            tint = textColor,
          )
        }
      }

      Row(Modifier.fillMaxWidth()) {
        weekdayLabels.forEach { label ->
          Text(
            text = label,
            modifier = Modifier.weight(1f),
            color = mutedColor,
            fontSize = labelFontSize,
            textAlign = TextAlign.Center,
            maxLines = 1,
          )
        }
      }

      cells.chunked(7).forEach { week ->
        Row(Modifier.fillMaxWidth()) {
          week.forEach { day ->
            Box(
              modifier = Modifier
                .weight(1f)
                .aspectRatio(1f),
              contentAlignment = Alignment.Center,
            ) {
              if (day != null) {
                val isToday = isSameDay(today, focusedMonth.get(Calendar.YEAR), focusedMonth.get(Calendar.MONTH), day)
                val isSelected = isSameDay(selectedDay, focusedMonth.get(Calendar.YEAR), focusedMonth.get(Calendar.MONTH), day)
                val background = when {
                  isSelected -> if (nightMode) colors.onSurface.copy(alpha = 0.85f) else colors.primary
                  else -> Color.Transparent
                }
                val accent = if (nightMode) colors.onSurface.copy(alpha = 0.6f) else colors.primary
                val labelColor = when {
                  isSelected && nightMode -> colors.surface
                  isSelected -> colors.onPrimary
                  isToday -> accent
                  else -> textColor
                }
                Box(
                  modifier = Modifier
                    .size(cellSize * 0.72f)
                    .clip(CircleShape)
                    .background(background)
                    .then(
                      if (isToday && !isSelected) {
                        Modifier.border(1.dp, accent, CircleShape)
                      } else {
                        Modifier
                      },
                    )
                    .clickable { onDaySelected(day) },
                  contentAlignment = Alignment.Center,
                ) {
                  Text(
                    text = day.toString(),
                    color = labelColor,
                    fontSize = dayFontSize,
                    fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                    maxLines = 1,
                  )
                }
              }
            }
          }
        }
      }
    }
  }
}
