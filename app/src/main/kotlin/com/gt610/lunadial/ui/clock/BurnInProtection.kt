package com.gt610.lunadial.ui.clock

import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.animateOffsetAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay

private val BURN_IN_OFFSETS = listOf(
  Offset(0f, 0f),
  Offset(3f, -2f),
  Offset(-2f, 2f),
  Offset(2f, 3f),
  Offset(-3f, -1f),
)

private const val STEP_MILLIS = 45_000L
private const val ANIMATION_MILLIS = 900

/**
 * Shifts its content by a few density-independent pixels every 45 seconds while
 * enabled, which breaks up static image retention on OLED panels without being
 * noticeable in use.
 */
@Composable
fun BurnInProtection(
  enabled: Boolean,
  modifier: Modifier = Modifier,
  content: @Composable () -> Unit,
) {
  var index by remember { mutableIntStateOf(0) }
  LaunchedEffect(enabled) {
    if (!enabled) {
      index = 0
      return@LaunchedEffect
    }
    while (true) {
      delay(STEP_MILLIS)
      index = (index + 1) % BURN_IN_OFFSETS.size
    }
  }

  val target = if (enabled) BURN_IN_OFFSETS[index] else Offset.Zero
  val animated by animateOffsetAsState(
    targetValue = target,
    animationSpec = tween(durationMillis = ANIMATION_MILLIS, easing = LinearOutSlowInEasing),
    label = "burn-in-offset",
  )
  val density = LocalDensity.current

  Box(
    modifier = modifier.graphicsLayer {
      translationX = with(density) { animated.x.dp.toPx() }
      translationY = with(density) { animated.y.dp.toPx() }
    },
  ) {
    content()
  }
}
