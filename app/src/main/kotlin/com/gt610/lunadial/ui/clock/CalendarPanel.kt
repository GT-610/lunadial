package com.gt610.lunadial.ui.clock

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gt610.lunadial.util.formatWithPattern
import com.gt610.lunadial.util.monthCells
import com.gt610.lunadial.util.rememberLocale
import com.gt610.lunadial.util.weekdayNarrowLabels
import java.util.Calendar

/**
 * The month grid in the style of a bedside calendar: month name in the accent
 * colour, single-letter weekday headers, plain numerals, and today marked with
 * a filled accent circle.
 */
@Composable
fun CalendarPanel(
  today: Calendar,
  nightMode: Boolean,
  modifier: Modifier = Modifier,
) {
  val locale = rememberLocale()
  val colors = MaterialTheme.colorScheme
  val accent = colors.primary
  val dayColor = if (nightMode) androidx.compose.ui.graphics.Color.White else colors.onSurface
  val mutedColor = dayColor.copy(alpha = 0.45f)

  val monthName = remember(today.get(Calendar.YEAR), today.get(Calendar.MONTH), locale) {
    formatWithPattern(today.time, "MMMM", locale).uppercase(locale)
  }
  val weekdayLabels = remember(locale) { weekdayNarrowLabels(locale) }
  val cells = remember(today.get(Calendar.YEAR), today.get(Calendar.MONTH)) {
    monthCells(today)
  }

  BoxWithConstraints(modifier = modifier) {
    val width = maxWidth
    val cellWidth = width / 7
    val rowHeight = cellWidth * 0.84f
    val monthFontSize: TextUnit = (width.value * 0.095f).coerceIn(16f, 38f).sp
    val weekdayFontSize: TextUnit = (width.value * 0.042f).coerceIn(9f, 17f).sp
    val dayFontSize: TextUnit = (width.value * 0.058f).coerceIn(11f, 24f).sp

    Column(modifier = Modifier.fillMaxWidth()) {
      Text(
        text = monthName,
        color = accent,
        fontSize = monthFontSize,
        fontWeight = FontWeight.SemiBold,
        letterSpacing = 1.sp,
        maxLines = 1,
        modifier = Modifier.padding(bottom = cellWidth * 0.28f),
      )

      Row(modifier = Modifier.fillMaxWidth()) {
        weekdayLabels.forEach { label ->
          Text(
            text = label,
            modifier = Modifier.weight(1f),
            color = mutedColor,
            fontSize = weekdayFontSize,
            fontWeight = FontWeight.Medium,
            textAlign = TextAlign.Center,
            maxLines = 1,
          )
        }
      }

      Column(Modifier.padding(top = cellWidth * 0.18f)) {
        cells.chunked(7).forEach { week ->
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .height(rowHeight),
            verticalAlignment = Alignment.CenterVertically,
          ) {
            week.forEach { day ->
              Box(
                modifier = Modifier
                  .weight(1f)
                  .height(rowHeight),
                contentAlignment = Alignment.Center,
              ) {
                if (day != null) {
                  val isToday = day == today.get(Calendar.DAY_OF_MONTH)
                  Box(
                    modifier = Modifier
                      .size(cellWidth * 0.76f)
                      .clip(CircleShape)
                      .background(
                        if (isToday) accent else androidx.compose.ui.graphics.Color.Transparent,
                      ),
                    contentAlignment = Alignment.Center,
                  ) {
                    Text(
                      text = day.toString(),
                      color = if (isToday) colors.onPrimary else dayColor,
                      fontSize = dayFontSize,
                      fontWeight = if (isToday) FontWeight.Medium else FontWeight.Normal,
                      textAlign = TextAlign.Center,
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
}
