package com.gt610.lunadial.ui.settings

import android.app.TimePickerDialog
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.gt610.lunadial.BuildConfig
import com.gt610.lunadial.R
import com.gt610.lunadial.model.ACCENT_PRESETS
import com.gt610.lunadial.model.AppSettings
import com.gt610.lunadial.model.ClockDisplayMode
import com.gt610.lunadial.model.LocaleOption
import com.gt610.lunadial.model.NightModeBehavior
import com.gt610.lunadial.model.ThemeModeOption
import com.gt610.lunadial.model.TimeFormatOption
import com.gt610.lunadial.util.formatMinutesOfDay
import com.gt610.lunadial.util.resolveUse24Hour
import com.gt610.lunadial.util.rememberLocale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
  settings: AppSettings,
  onUpdate: ((AppSettings) -> AppSettings) -> Unit,
  onBack: () -> Unit,
) {
  val context = LocalContext.current
  val locale = rememberLocale()
  val use24Hour = resolveUse24Hour(context, settings.timeFormat)

  var showThemeColor by remember { mutableStateOf(false) }
  var showThemeMode by remember { mutableStateOf(false) }
  var showLanguage by remember { mutableStateOf(false) }
  var showClockMode by remember { mutableStateOf(false) }
  var showTimeFormat by remember { mutableStateOf(false) }
  var showNightMode by remember { mutableStateOf(false) }
  var showLicense by remember { mutableStateOf(false) }

  Scaffold(
    topBar = {
      TopAppBar(
        title = { Text(stringResource(R.string.settings)) },
        navigationIcon = {
          IconButton(onClick = onBack) {
            Icon(
              imageVector = Icons.AutoMirrored.Filled.ArrowBack,
              contentDescription = stringResource(R.string.back),
            )
          }
        },
      )
    },
  ) { padding ->
    LazyColumn(
      modifier = Modifier
        .fillMaxWidth()
        .padding(padding),
      contentPadding = androidx.compose.foundation.layout.PaddingValues(
        start = 16.dp,
        end = 16.dp,
        top = 8.dp,
        bottom = 32.dp,
      ),
      verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
      item {
        SectionHeader(stringResource(R.string.appearance))
        SettingCard {
          ValueRow(
            title = stringResource(R.string.theme_color),
            value = null,
            leading = {
              Box(
                Modifier
                  .size(24.dp)
                  .clip(CircleShape)
                  .background(Color(settings.themeColor)),
              )
            },
            onClick = { showThemeColor = true },
          )
          RowDivider()
          SwitchRow(
            title = stringResource(R.string.use_dynamic_color),
            description = stringResource(R.string.use_dynamic_color_description),
            checked = settings.useDynamicColor,
            onCheckedChange = { enabled ->
              onUpdate { it.copy(useDynamicColor = enabled) }
            },
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.theme_mode),
            value = stringResource(settings.themeMode.labelRes()),
            onClick = { showThemeMode = true },
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.language),
            value = stringResource(settings.locale.labelRes()),
            onClick = { showLanguage = true },
          )
        }
      }

      item {
        SectionHeader(stringResource(R.string.display))
        SettingCard {
          ValueRow(
            title = stringResource(R.string.clock_display_mode),
            value = stringResource(
              if (settings.clockDisplayMode == ClockDisplayMode.DIGITAL) {
                R.string.digital_clock
              } else {
                R.string.analog_clock
              },
            ),
            onClick = { showClockMode = true },
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.time_format),
            value = stringResource(settings.timeFormat.labelRes()),
            onClick = { showTimeFormat = true },
          )
          RowDivider()
          SwitchRow(
            title = stringResource(R.string.show_seconds),
            checked = settings.showSeconds,
            onCheckedChange = { enabled -> onUpdate { it.copy(showSeconds = enabled) } },
          )
          RowDivider()
          SwitchRow(
            title = stringResource(R.string.leading_zero),
            description = stringResource(R.string.leading_zero_description),
            checked = settings.leadingZero,
            onCheckedChange = { enabled -> onUpdate { it.copy(leadingZero = enabled) } },
          )
          RowDivider()
          SwitchRow(
            title = stringResource(R.string.keep_screen_on),
            checked = settings.keepScreenOn,
            onCheckedChange = { enabled -> onUpdate { it.copy(keepScreenOn = enabled) } },
          )
        }
      }

      item {
        SectionHeader(stringResource(R.string.night_and_burn_in))
        SettingCard {
          ValueRow(
            title = stringResource(R.string.night_display_mode),
            description = stringResource(R.string.night_display_mode_description),
            value = stringResource(settings.nightMode.labelRes()),
            onClick = { showNightMode = true },
          )
          if (settings.nightMode == NightModeBehavior.SCHEDULED) {
            RowDivider()
            ValueRow(
              title = stringResource(R.string.night_mode_start_time),
              value = formatMinutesOfDay(settings.nightStartMinutes, use24Hour, locale),
              onClick = {
                showTimePicker(context, settings.nightStartMinutes, use24Hour) { minutes ->
                  onUpdate { it.copy(nightStartMinutes = minutes) }
                }
              },
            )
            RowDivider()
            ValueRow(
              title = stringResource(R.string.night_mode_end_time),
              value = formatMinutesOfDay(settings.nightEndMinutes, use24Hour, locale),
              onClick = {
                showTimePicker(context, settings.nightEndMinutes, use24Hour) { minutes ->
                  onUpdate { it.copy(nightEndMinutes = minutes) }
                }
              },
            )
          }
          RowDivider()
          SwitchRow(
            title = stringResource(R.string.burn_in_protection),
            description = stringResource(R.string.burn_in_protection_description),
            checked = settings.burnInProtection,
            onCheckedChange = { enabled ->
              onUpdate { it.copy(burnInProtection = enabled) }
            },
          )
        }
      }

      item {
        SectionHeader(stringResource(R.string.information))
        SettingCard {
          ValueRow(
            title = stringResource(R.string.version),
            value = BuildConfig.VERSION_NAME,
            onClick = null,
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.license),
            value = "GPL-3.0",
            onClick = { showLicense = true },
          )
        }
      }
    }
  }

  if (showThemeColor) {
    ColorPickerDialog(
      selected = settings.themeColor,
      onSelect = { color ->
        onUpdate { it.copy(themeColor = color) }
        showThemeColor = false
      },
      onDismiss = { showThemeColor = false },
    )
  }

  if (showThemeMode) {
    OptionDialog(
      title = stringResource(R.string.theme_mode),
      options = listOf(
        ThemeModeOption.SYSTEM to stringResource(R.string.system),
        ThemeModeOption.LIGHT to stringResource(R.string.light),
        ThemeModeOption.DARK to stringResource(R.string.dark),
        ThemeModeOption.OLED to stringResource(R.string.oled),
      ),
      selected = settings.themeMode,
      onSelect = { mode ->
        onUpdate { it.copy(themeMode = mode) }
        showThemeMode = false
      },
      onDismiss = { showThemeMode = false },
    )
  }

  if (showLanguage) {
    OptionDialog(
      title = stringResource(R.string.language),
      options = listOf(
        LocaleOption.SYSTEM to stringResource(R.string.follow_system),
        LocaleOption.ENGLISH to stringResource(R.string.english),
        LocaleOption.CHINESE_SIMPLIFIED to stringResource(R.string.chinese),
      ),
      selected = settings.locale,
      onSelect = { option ->
        onUpdate { it.copy(locale = option) }
        showLanguage = false
      },
      onDismiss = { showLanguage = false },
    )
  }

  if (showClockMode) {
    OptionDialog(
      title = stringResource(R.string.clock_display_mode),
      options = listOf(
        ClockDisplayMode.DIGITAL to stringResource(R.string.digital_clock),
        ClockDisplayMode.ANALOG to stringResource(R.string.analog_clock),
      ),
      selected = settings.clockDisplayMode,
      onSelect = { mode ->
        onUpdate { it.copy(clockDisplayMode = mode) }
        showClockMode = false
      },
      onDismiss = { showClockMode = false },
    )
  }

  if (showTimeFormat) {
    OptionDialog(
      title = stringResource(R.string.time_format),
      options = listOf(
        TimeFormatOption.SYSTEM to stringResource(R.string.follow_system),
        TimeFormatOption.TWELVE_HOUR to stringResource(R.string.twelve_hour),
        TimeFormatOption.TWENTY_FOUR_HOUR to stringResource(R.string.twenty_four_hour),
      ),
      selected = settings.timeFormat,
      onSelect = { format ->
        onUpdate { it.copy(timeFormat = format) }
        showTimeFormat = false
      },
      onDismiss = { showTimeFormat = false },
    )
  }

  if (showNightMode) {
    OptionDialog(
      title = stringResource(R.string.night_display_mode),
      options = listOf(
        NightModeBehavior.OFF to stringResource(R.string.night_mode_off),
        NightModeBehavior.ON to stringResource(R.string.night_mode_on),
        NightModeBehavior.SCHEDULED to stringResource(R.string.night_mode_scheduled),
        NightModeBehavior.FOLLOW_SYSTEM to stringResource(R.string.night_mode_follow_system),
      ),
      selected = settings.nightMode,
      onSelect = { behavior ->
        onUpdate { it.copy(nightMode = behavior) }
        showNightMode = false
      },
      onDismiss = { showNightMode = false },
    )
  }

  if (showLicense) {
    AlertDialog(
      onDismissRequest = { showLicense = false },
      confirmButton = {
        TextButton(onClick = { showLicense = false }) {
          Text(stringResource(R.string.close))
        }
      },
      title = { Text(stringResource(R.string.license)) },
      text = { Text(stringResource(R.string.license_body)) },
    )
  }
}

private fun showTimePicker(
  context: android.content.Context,
  initialMinutes: Int,
  use24Hour: Boolean,
  onPicked: (Int) -> Unit,
) {
  TimePickerDialog(
    context,
    { _, hour, minute -> onPicked(hour * 60 + minute) },
    initialMinutes / 60,
    initialMinutes % 60,
    use24Hour,
  ).show()
}

@Composable
private fun SectionHeader(text: String) {
  Text(
    text = text,
    style = MaterialTheme.typography.labelLarge,
    color = MaterialTheme.colorScheme.primary,
    fontWeight = FontWeight.SemiBold,
    modifier = Modifier.padding(start = 4.dp, top = 16.dp, bottom = 4.dp),
  )
}

@Composable
private fun SettingCard(content: @Composable () -> Unit) {
  Card(
    colors = CardDefaults.cardColors(
      containerColor = MaterialTheme.colorScheme.surfaceContainer,
    ),
    modifier = Modifier.fillMaxWidth(),
  ) {
    Column { content() }
  }
}

@Composable
private fun RowDivider() {
  HorizontalDivider(
    color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f),
    modifier = Modifier.padding(start = 16.dp),
  )
}

@Composable
private fun ValueRow(
  title: String,
  value: String?,
  onClick: (() -> Unit)?,
  description: String? = null,
  leading: (@Composable () -> Unit)? = null,
) {
  Row(
    modifier = Modifier
      .fillMaxWidth()
      .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
      .padding(horizontal = 16.dp, vertical = 14.dp),
    verticalAlignment = Alignment.CenterVertically,
  ) {
    if (leading != null) {
      leading()
      Box(Modifier.padding(end = 12.dp))
    }
    Column(Modifier.weight(1f)) {
      Text(text = title, style = MaterialTheme.typography.bodyLarge)
      if (description != null) {
        Text(
          text = description,
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          modifier = Modifier.padding(top = 2.dp),
        )
      }
    }
    if (value != null) {
      Text(
        text = value,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.padding(start = 12.dp),
      )
    }
  }
}

@Composable
private fun SwitchRow(
  title: String,
  checked: Boolean,
  onCheckedChange: (Boolean) -> Unit,
  description: String? = null,
) {
  Row(
    modifier = Modifier
      .fillMaxWidth()
      .clickable { onCheckedChange(!checked) }
      .padding(horizontal = 16.dp, vertical = 12.dp),
    verticalAlignment = Alignment.CenterVertically,
  ) {
    Column(Modifier.weight(1f)) {
      Text(text = title, style = MaterialTheme.typography.bodyLarge)
      if (description != null) {
        Text(
          text = description,
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          modifier = Modifier.padding(top = 2.dp),
        )
      }
    }
    Switch(checked = checked, onCheckedChange = onCheckedChange)
  }
}

@Composable
private fun <T> OptionDialog(
  title: String,
  options: List<Pair<T, String>>,
  selected: T,
  onSelect: (T) -> Unit,
  onDismiss: () -> Unit,
) {
  AlertDialog(
    onDismissRequest = onDismiss,
    confirmButton = {},
    dismissButton = {
      TextButton(onClick = onDismiss) { Text(stringResource(R.string.close)) }
    },
    title = { Text(title) },
    text = {
      Column {
        options.forEach { (value, label) ->
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .clickable { onSelect(value) }
              .padding(vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
          ) {
            RadioButton(selected = value == selected, onClick = { onSelect(value) })
            Text(text = label, style = MaterialTheme.typography.bodyLarge)
          }
        }
      }
    },
  )
}

@Composable
private fun ColorPickerDialog(
  selected: Int,
  onSelect: (Int) -> Unit,
  onDismiss: () -> Unit,
) {
  AlertDialog(
    onDismissRequest = onDismiss,
    confirmButton = {},
    dismissButton = {
      TextButton(onClick = onDismiss) { Text(stringResource(R.string.close)) }
    },
    title = { Text(stringResource(R.string.select_theme_color)) },
    text = {
      Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        ACCENT_PRESETS.chunked(5).forEach { row ->
          Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            row.forEach { color ->
              Box(
                modifier = Modifier
                  .size(40.dp)
                  .clip(CircleShape)
                  .background(Color(color))
                  .then(
                    if (color == selected) {
                      Modifier.border(3.dp, MaterialTheme.colorScheme.onSurface, CircleShape)
                    } else {
                      Modifier
                    },
                  )
                  .clickable { onSelect(color) },
              )
            }
          }
        }
      }
    },
  )
}

private fun ThemeModeOption.labelRes(): Int = when (this) {
  ThemeModeOption.SYSTEM -> R.string.system
  ThemeModeOption.LIGHT -> R.string.light
  ThemeModeOption.DARK -> R.string.dark
  ThemeModeOption.OLED -> R.string.oled
}

private fun LocaleOption.labelRes(): Int = when (this) {
  LocaleOption.SYSTEM -> R.string.follow_system
  LocaleOption.ENGLISH -> R.string.english
  LocaleOption.CHINESE_SIMPLIFIED -> R.string.chinese
}

private fun TimeFormatOption.labelRes(): Int = when (this) {
  TimeFormatOption.SYSTEM -> R.string.follow_system
  TimeFormatOption.TWELVE_HOUR -> R.string.twelve_hour
  TimeFormatOption.TWENTY_FOUR_HOUR -> R.string.twenty_four_hour
}

private fun NightModeBehavior.labelRes(): Int = when (this) {
  NightModeBehavior.OFF -> R.string.night_mode_off
  NightModeBehavior.ON -> R.string.night_mode_on
  NightModeBehavior.SCHEDULED -> R.string.night_mode_scheduled
  NightModeBehavior.FOLLOW_SYSTEM -> R.string.night_mode_follow_system
}
