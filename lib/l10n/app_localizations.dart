import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'LunaDial'**
  String get appTitle;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Appearance settings section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Appearance settings section description
  ///
  /// In en, this message translates to:
  /// **'Customize the look and feel of LunaDial'**
  String get appearanceDescription;

  /// Theme color setting title
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// Theme color setting description
  ///
  /// In en, this message translates to:
  /// **'Choose the primary color for the clock'**
  String get themeColorDescription;

  /// Theme mode setting title
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Theme mode setting description
  ///
  /// In en, this message translates to:
  /// **'Choose between light, dark, or system theme'**
  String get themeModeDescription;

  /// Screen settings section title
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get screen;

  /// Screen settings section description
  ///
  /// In en, this message translates to:
  /// **'Configure screen behavior'**
  String get screenDescription;

  /// Keep screen on setting title
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On'**
  String get keepScreenOn;

  /// Keep screen on setting description
  ///
  /// In en, this message translates to:
  /// **'Prevent the screen from turning off'**
  String get keepScreenOnDescription;

  /// Clock style settings section title
  ///
  /// In en, this message translates to:
  /// **'Clock Style'**
  String get clockStyle;

  /// Clock style settings section description
  ///
  /// In en, this message translates to:
  /// **'Change how the time is displayed'**
  String get clockStyleDescription;

  /// Digital clock setting title
  ///
  /// In en, this message translates to:
  /// **'Digital Clock'**
  String get digitalClock;

  /// Digital clock setting description
  ///
  /// In en, this message translates to:
  /// **'Use digital format instead of analog'**
  String get digitalClockDescription;

  /// Information settings section title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Information settings section description
  ///
  /// In en, this message translates to:
  /// **'Learn more about LunaDial'**
  String get informationDescription;

  /// Version setting title
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Version setting description
  ///
  /// In en, this message translates to:
  /// **'Current version of LunaDial'**
  String get versionDescription;

  /// License setting title
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// License setting description
  ///
  /// In en, this message translates to:
  /// **'View license information'**
  String get licenseDescription;

  /// Contributors setting title
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors;

  /// Contributors setting description
  ///
  /// In en, this message translates to:
  /// **'List of contributors to this project'**
  String get contributorsDescription;

  /// System theme mode option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Light theme mode option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme mode option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Dialog title for selecting theme color
  ///
  /// In en, this message translates to:
  /// **'Select Theme Color'**
  String get selectThemeColor;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language setting description
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get languageDescription;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Simplified Chinese language option
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get chinese;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Date format pattern for digital clock display
  ///
  /// In en, this message translates to:
  /// **'EEEE, MMMM d, yyyy'**
  String get dateFormat;

  /// Format pattern for calendar header showing month and year
  ///
  /// In en, this message translates to:
  /// **'MMMM yyyy'**
  String get calendarHeaderFormat;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
