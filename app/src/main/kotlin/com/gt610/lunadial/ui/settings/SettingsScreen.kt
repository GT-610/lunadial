package com.gt610.lunadial.ui.settings

import android.app.TimePickerDialog
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
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
import com.gt610.lunadial.util.rememberLocale
import com.gt610.lunadial.util.resolveUse24Hour

/** The bottom sheets the settings screen can show; only one at a time. */
private enum class SettingsSheet {
  THEME_COLOR,
  THEME_MODE,
  LANGUAGE,
  TIME_FORMAT,
  NIGHT_MODE,
  LICENSE,
}

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

  var sheet by remember { mutableStateOf<SettingsSheet?>(null) }
  var showStartPicker by remember { mutableStateOf(false) }
  var showEndPicker by remember { mutableStateOf(false) }

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
        .fillMaxSize()
        .padding(padding),
      contentPadding = PaddingValues(bottom = 32.dp),
    ) {
      item { SectionHeader(stringResource(R.string.appearance)) }
      item {
        SettingsGroup {
          ListItem(
            headlineContent = { Text(stringResource(R.string.theme_color)) },
            leadingContent = {
              Box(
                Modifier
                  .size(24.dp)
                  .clip(CircleShape)
                  .background(Color(settings.themeColor)),
              )
            },
            trailingContent = { TrailingChevron() },
            modifier = Modifier.clickable { sheet = SettingsSheet.THEME_COLOR },
            colors = ListItemDefaults.colors(containerColor = Color.Transparent),
          )
          RowDivider()
          SwitchRow(
            title = stringResource(R.string.use_dynamic_color),
            description = stringResource(R.string.use_dynamic_color_description),
            checked = settings.useDynamicColor,
            onCheckedChange = { enabled -> onUpdate { it.copy(useDynamicColor = enabled) } },
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.theme_mode),
            value = stringResource(settings.themeMode.labelRes()),
            onClick = { sheet = SettingsSheet.THEME_MODE },
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.language),
            value = stringResource(settings.locale.labelRes()),
            onClick = { sheet = SettingsSheet.LANGUAGE },
          )
        }
      }

      item { SectionHeader(stringResource(R.string.display)) }
      item {
        SettingsGroup {
          SegmentedRow(
            title = stringResource(R.string.clock_display_mode),
            options = listOf(
              ClockDisplayMode.DIGITAL to stringResource(R.string.digital_clock),
              ClockDisplayMode.ANALOG to stringResource(R.string.analog_clock),
            ),
            selected = settings.clockDisplayMode,
            onSelect = { mode -> onUpdate { it.copy(clockDisplayMode = mode) } },
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.time_format),
            value = stringResource(settings.timeFormat.labelRes()),
            onClick = { sheet = SettingsSheet.TIME_FORMAT },
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

      item { SectionHeader(stringResource(R.string.night_and_burn_in)) }
      item {
        SettingsGroup {
          ValueRow(
            title = stringResource(R.string.night_display_mode),
            description = stringResource(R.string.night_display_mode_description),
            value = stringResource(settings.nightMode.labelRes()),
            onClick = { sheet = SettingsSheet.NIGHT_MODE },
          )
          if (settings.nightMode == NightModeBehavior.SCHEDULED) {
            RowDivider()
            ValueRow(
              title = stringResource(R.string.night_mode_start_time),
              value = formatMinutesOfDay(settings.nightStartMinutes, use24Hour, locale),
              onClick = { showStartPicker = true },
            )
            RowDivider()
            ValueRow(
              title = stringResource(R.string.night_mode_end_time),
              value = formatMinutesOfDay(settings.nightEndMinutes, use24Hour, locale),
              onClick = { showEndPicker = true },
            )
          }
          RowDivider()
          SwitchRow(
            title = stringResource(R.string.burn_in_protection),
            description = stringResource(R.string.burn_in_protection_description),
            checked = settings.burnInProtection,
            onCheckedChange = { enabled -> onUpdate { it.copy(burnInProtection = enabled) } },
          )
        }
      }

      item { SectionHeader(stringResource(R.string.information)) }
      item {
        SettingsGroup {
          ValueRow(
            title = stringResource(R.string.version),
            value = BuildConfig.VERSION_NAME,
          )
          RowDivider()
          ValueRow(
            title = stringResource(R.string.license),
            value = "GPL-3.0",
            onClick = { sheet = SettingsSheet.LICENSE },
          )
        }
      }
    }
  }

  if (showStartPicker) {
    TimePicker(
      initialMinutes = settings.nightStartMinutes,
      use24Hour = use24Hour,
      onPicked = { minutes ->
        onUpdate { it.copy(nightStartMinutes = minutes) }
        showStartPicker = false
      },
      onDismiss = { showStartPicker = false },
    )
  }

  if (showEndPicker) {
    TimePicker(
      initialMinutes = settings.nightEndMinutes,
      use24Hour = use24Hour,
      onPicked = { minutes ->
        onUpdate { it.copy(nightEndMinutes = minutes) }
        showEndPicker = false
      },
      onDismiss = { showEndPicker = false },
    )
  }

  sheet?.let { current ->
    SettingsBottomSheet(
      sheet = current,
      settings = settings,
      onUpdate = onUpdate,
      onDismiss = { sheet = null },
    )
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SettingsBottomSheet(
  sheet: SettingsSheet,
  settings: AppSettings,
  onUpdate: ((AppSettings) -> AppSettings) -> Unit,
  onDismiss: () -> Unit,
) {
  val sheetState = rememberModalBottomSheetState()
  ModalBottomSheet(onDismissRequest = onDismiss, sheetState = sheetState) {
    Column(
      modifier = Modifier
        .fillMaxWidth()
        .padding(bottom = 24.dp),
    ) {
      when (sheet) {
        SettingsSheet.THEME_COLOR -> {
          SheetTitle(stringResource(R.string.select_theme_color))
          ColorGrid(
            selected = settings.themeColor,
            onSelect = { color ->
              onUpdate { it.copy(themeColor = color) }
              onDismiss()
            },
          )
        }

        SettingsSheet.THEME_MODE -> {
          SheetTitle(stringResource(R.string.theme_mode))
          ThemeModeOption.entries.forEach { mode ->
            OptionRow(
              label = stringResource(mode.labelRes()),
              selected = settings.themeMode == mode,
              onClick = {
                onUpdate { it.copy(themeMode = mode) }
                onDismiss()
              },
            )
          }
        }

        SettingsSheet.LANGUAGE -> {
          SheetTitle(stringResource(R.string.language))
          LocaleOption.entries.forEach { option ->
            OptionRow(
              label = stringResource(option.labelRes()),
              selected = settings.locale == option,
              onClick = {
                onUpdate { it.copy(locale = option) }
                onDismiss()
              },
            )
          }
        }

        SettingsSheet.TIME_FORMAT -> {
          SheetTitle(stringResource(R.string.time_format))
          TimeFormatOption.entries.forEach { format ->
            OptionRow(
              label = stringResource(format.labelRes()),
              selected = settings.timeFormat == format,
              onClick = {
                onUpdate { it.copy(timeFormat = format) }
                onDismiss()
              },
            )
          }
        }

        SettingsSheet.NIGHT_MODE -> {
          SheetTitle(stringResource(R.string.night_display_mode))
          NightModeBehavior.entries.forEach { behavior ->
            OptionRow(
              label = stringResource(behavior.labelRes()),
              description = stringResource(behavior.descriptionRes()),
              selected = settings.nightMode == behavior,
              onClick = {
                onUpdate { it.copy(nightMode = behavior) }
                onDismiss()
              },
            )
          }
        }

        SettingsSheet.LICENSE -> {
          SheetTitle(stringResource(R.string.license))
          Text(
            text = stringResource(R.string.license_body),
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier
              .padding(horizontal = 24.dp)
              .verticalScroll(rememberScrollState()),
          )
          TextButton(
            onClick = onDismiss,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
          ) {
            Text(stringResource(R.string.close))
          }
        }
      }
    }
  }
}

@Composable
private fun SheetTitle(text: String) {
  Text(
    text = text,
    style = MaterialTheme.typography.titleMedium,
    modifier = Modifier.padding(start = 24.dp, end = 24.dp, top = 4.dp, bottom = 12.dp),
  )
}

@Composable
private fun SectionHeader(text: String) {
  Text(
    text = text,
    style = MaterialTheme.typography.titleSmall,
    color = MaterialTheme.colorScheme.primary,
    modifier = Modifier.padding(start = 28.dp, end = 16.dp, top = 20.dp, bottom = 8.dp),
  )
}

@Composable
private fun SettingsGroup(content: @Composable () -> Unit) {
  Card(
    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainer),
    modifier = Modifier
      .fillMaxWidth()
      .padding(horizontal = 16.dp),
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
private fun TrailingChevron() {
  Icon(
    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
    contentDescription = null,
    tint = MaterialTheme.colorScheme.onSurfaceVariant,
  )
}

@Composable
private fun ValueRow(
  title: String,
  value: String? = null,
  description: String? = null,
  onClick: (() -> Unit)? = null,
) {
  ListItem(
    headlineContent = { Text(title) },
    supportingContent = description?.let { { Text(it) } },
    trailingContent = {
      Row(verticalAlignment = Alignment.CenterVertically) {
        if (value != null) {
          Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.End,
          )
        }
        if (onClick != null) TrailingChevron()
      }
    },
    modifier = if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier,
    colors = ListItemDefaults.colors(containerColor = Color.Transparent),
  )
}

@Composable
private fun SwitchRow(
  title: String,
  checked: Boolean,
  onCheckedChange: (Boolean) -> Unit,
  description: String? = null,
) {
  ListItem(
    headlineContent = { Text(title) },
    supportingContent = description?.let { { Text(it) } },
    trailingContent = { Switch(checked = checked, onCheckedChange = onCheckedChange) },
    modifier = Modifier.clickable { onCheckedChange(!checked) },
    colors = ListItemDefaults.colors(containerColor = Color.Transparent),
  )
}

@Composable
private fun <T> SegmentedRow(
  title: String,
  options: List<Pair<T, String>>,
  selected: T,
  onSelect: (T) -> Unit,
) {
  Column(Modifier.padding(horizontal = 16.dp, vertical = 12.dp)) {
    Text(
      text = title,
      style = MaterialTheme.typography.bodyLarge,
      modifier = Modifier.padding(bottom = 10.dp),
    )
    SingleChoiceSegmentedButtonRow(Modifier.fillMaxWidth()) {
      options.forEachIndexed { index, (value, label) ->
        SegmentedButton(
          selected = value == selected,
          onClick = { onSelect(value) },
          shape = SegmentedButtonDefaults.itemShape(index = index, count = options.size),
          label = { Text(label) },
        )
      }
    }
  }
}

@Composable
private fun OptionRow(
  label: String,
  selected: Boolean,
  onClick: () -> Unit,
  description: String? = null,
) {
  ListItem(
    headlineContent = { Text(label) },
    supportingContent = description?.let { { Text(it) } },
    trailingContent = { RadioButton(selected = selected, onClick = null) },
    modifier = Modifier.clickable(onClick = onClick),
    colors = ListItemDefaults.colors(containerColor = Color.Transparent),
  )
}

@Composable
private fun ColorGrid(selected: Int, onSelect: (Int) -> Unit) {
  Column(
    modifier = Modifier
      .fillMaxWidth()
      .padding(horizontal = 24.dp),
    verticalArrangement = Arrangement.spacedBy(12.dp),
  ) {
    ACCENT_PRESETS.chunked(5).forEach { row ->
      Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        row.forEach { color ->
          Box(
            modifier = Modifier
              .size(44.dp)
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
}

@Composable
private fun TimePicker(
  initialMinutes: Int,
  use24Hour: Boolean,
  onPicked: (Int) -> Unit,
  onDismiss: () -> Unit,
) {
  val context = LocalContext.current
  val currentOnPicked by rememberUpdatedState(onPicked)
  val currentOnDismiss by rememberUpdatedState(onDismiss)
  DisposableEffect(initialMinutes, use24Hour) {
    val dialog = TimePickerDialog(
      context,
      { _, hour, minute -> currentOnPicked(hour * 60 + minute) },
      initialMinutes / 60,
      initialMinutes % 60,
      use24Hour,
    )
    dialog.setOnCancelListener { currentOnDismiss() }
    dialog.show()
    onDispose { dialog.dismiss() }
  }
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

private fun NightModeBehavior.descriptionRes(): Int = when (this) {
  NightModeBehavior.OFF -> R.string.night_mode_off_description
  NightModeBehavior.ON -> R.string.night_mode_on_description
  NightModeBehavior.SCHEDULED -> R.string.night_mode_scheduled_description
  NightModeBehavior.FOLLOW_SYSTEM -> R.string.night_mode_follow_system_description
}
