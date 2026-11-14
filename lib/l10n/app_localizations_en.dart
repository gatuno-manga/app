// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authSignInTitle => 'Gatuno';

  @override
  String get authSignInSubtitle =>
      'Gatuno is a system developed to organize and share a personal collection of e-books on a local network.';

  @override
  String get authSignUpTitle => 'Join Gatuno';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailError => 'Please enter your email';

  @override
  String get authEmailInvalid => 'Please enter a valid email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordError => 'Please enter your password';

  @override
  String get authPasswordTooShort =>
      'Password must be at least 8 characters long';

  @override
  String get authPasswordNoUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get authPasswordNoNumber =>
      'Password must contain at least one number';

  @override
  String get authPasswordNoSymbol =>
      'Password must contain at least one symbol';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authConfirmPasswordError => 'Please confirm your password';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authSignInButton => 'SIGN IN';

  @override
  String get authSignUpButton => 'SIGN UP';

  @override
  String get authCreateAccountButton => 'CREATE ACCOUNT';

  @override
  String get authDoNotHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeFeaturedReadNow => 'Read now';

  @override
  String get homeContinueReadingTitle => 'Continue reading';

  @override
  String get homeLatestUpdatesTitle => 'Latest Updates';

  @override
  String get homeRecentlyAddedTitle => 'New on Gatuno';

  @override
  String get homeViewAll => 'View all';

  @override
  String get booksTitle => 'Books';

  @override
  String get booksSearchHint => 'Search books...';

  @override
  String get booksFilterTitle => 'Filters';

  @override
  String get booksApplyFilters => 'Apply Filters';

  @override
  String get booksClearFilters => 'Clear';

  @override
  String get booksPublicationYear => 'Publication Year';

  @override
  String get booksTypes => 'Types';

  @override
  String get booksSensitiveContent => 'Sensitive Content';

  @override
  String get booksTags => 'Tags';

  @override
  String get booksIncludedTags => 'Included Tags';

  @override
  String get booksExcludedTags => 'Excluded Tags';

  @override
  String get booksAuthors => 'Authors';

  @override
  String get booksFilterAdd => 'Add';

  @override
  String get booksFilterSearchHint => 'Search...';

  @override
  String get booksFilterNoOptions => 'No options found';

  @override
  String get booksFilterLoadError => 'Could not load options';

  @override
  String get booksFilterRetry => 'Try again';

  @override
  String get booksFilterDone => 'Done';

  @override
  String get booksFilterLogicAll => 'All';

  @override
  String get booksFilterLogicAny => 'Any';

  @override
  String get booksOperatorBefore => 'Before';

  @override
  String get booksOperatorBeforeEqual => 'Before or Equal to';

  @override
  String get booksOperatorAfter => 'After';

  @override
  String get booksOperatorAfterEqual => 'After or Equal to';

  @override
  String get booksOperatorEqual => 'Equal';

  @override
  String get bookTypeManga => 'Manga';

  @override
  String get bookTypeManhwa => 'Manhwa';

  @override
  String get bookTypeManhua => 'Manhua';

  @override
  String get bookTypeBook => 'Book';

  @override
  String get bookTypeOther => 'Other';

  @override
  String get bookTypeUnknown => 'Unknown';

  @override
  String get booksUnknownAuthor => 'Unknown Author';

  @override
  String get booksNoBooksFound => 'No books found';

  @override
  String get booksNoChaptersFound => 'No chapters found';

  @override
  String get booksChapterCount => 'Chapters';

  @override
  String booksChapterLabel(String index) {
    return 'Chapter $index';
  }

  @override
  String get booksSortTitle => 'Sort';

  @override
  String get booksSortMostRecentAdded => 'Most Recent Added';

  @override
  String get booksSortOldestAdded => 'Oldest Added';

  @override
  String get booksSortAlphabeticalAZ => 'Alphabetical A-Z';

  @override
  String get booksSortAlphabeticalZA => 'Alphabetical Z-A';

  @override
  String get booksSortMostRecentUpdate => 'Most Recent Update';

  @override
  String get booksSortOldestUpdate => 'Oldest Update';

  @override
  String get booksSortMostRecentPublished => 'Most Recent Published';

  @override
  String get booksSortOldestPublished => 'Oldest Published';

  @override
  String get booksViewOptions => 'View options';

  @override
  String get booksViewGrid => 'Grid';

  @override
  String get booksViewList => 'List';

  @override
  String get booksViewCover => 'Covers';

  @override
  String get booksViewColumns => 'Columns';

  @override
  String get booksViewNavigation => 'Navigation';

  @override
  String get booksViewNavigationPages => 'Pages';

  @override
  String get booksViewNavigationInfinite => 'Infinite scroll';

  @override
  String get scrapingStatusReady => 'Ready';

  @override
  String get scrapingStatusProcess => 'Processing';

  @override
  String get scrapingStatusError => 'Error';

  @override
  String get scrapingStatusProcessWarning =>
      'This chapter is still being processed and is not yet available for reading.';

  @override
  String get scrapingStatusErrorWarning =>
      'This chapter encountered an error during processing and cannot be read.';

  @override
  String get booksStartReading => 'Start Reading';

  @override
  String get booksContinueReading => 'Continue Reading';

  @override
  String get homeWelcome => 'Welcome to Gatuno!';

  @override
  String get homeProfile => 'Profile';

  @override
  String get homeSignIn => 'Sign in';

  @override
  String get userMeTitle => 'My Profile';

  @override
  String get userMeSensitiveContent => 'Sensitive Content';

  @override
  String get userMeSensitiveContentDesc => 'Show books with sensitive content';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeTrueDark => 'True dark';

  @override
  String get settingsThemeDracula => 'Dracula';

  @override
  String get settingsThemeSlate => 'Slate';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsReadingSection => 'Reading';

  @override
  String get settingsApiSection => 'API Configuration';

  @override
  String get settingsApiUrlLabel => 'API Base URL';

  @override
  String get settingsApiUrlHint => 'http://your-api.com/api';

  @override
  String get settingsApiUrlSuccess => 'API URL updated successfully';

  @override
  String get settingsApiUrlError => 'Error updating API URL';

  @override
  String get settingsAllowedUrlsSection => 'Allowed Bad Certificates';

  @override
  String get settingsAddUrlLabel => 'Add URL';

  @override
  String get settingsAddUrlHint => 'https://example.com';

  @override
  String get settingsRemoveUrl => 'Remove';

  @override
  String get settingsCertificatesSection => 'Certificates';

  @override
  String get settingsCertificatesDesc =>
      'Manage trusted and ignored certificates';

  @override
  String get settingsDiagnosticsSection => 'Diagnostics';

  @override
  String get settingsExportLogs => 'Export Logs';

  @override
  String get settingsExportLogsDesc => 'Share the app log file';

  @override
  String get settingsOpenLogs => 'Open Logs';

  @override
  String get settingsOpenLogsDesc => 'View logs on this device';

  @override
  String get certTrustDialogTitle => 'Untrusted Certificate';

  @override
  String certTrustDialogMessage(String name) {
    return 'The server at $name is using an untrusted certificate. Do you want to trust it and continue?';
  }

  @override
  String get certTrustDialogTrust => 'Trust';

  @override
  String get certTrustDialogIgnore => 'Ignore';

  @override
  String get certTrustedTab => 'Trusted';

  @override
  String get certIgnoredTab => 'Ignored';

  @override
  String get certAddTitle => 'Add Certificate';

  @override
  String get certAddLabel => 'Name';

  @override
  String get certAddHint => 'api.example.com';

  @override
  String get certAddPemLabel => 'Certificate (PEM)';

  @override
  String get certAddFileButton => 'Select PEM File';

  @override
  String get certEmptyTrusted => 'No trusted certificates yet.';

  @override
  String get certEmptyIgnored => 'No ignored certificates yet.';

  @override
  String certFingerprintLabel(String fingerprint) {
    return 'Fingerprint: $fingerprint';
  }

  @override
  String get certDeleteConfirm =>
      'Are you sure you want to remove this certificate?';

  @override
  String get certErrorInvalidFormat => 'Invalid certificate format.';

  @override
  String get certErrorFileMissing =>
      'Certificate file is missing or unreadable.';

  @override
  String get certErrorDecoding => 'Failed to decode certificate file.';

  @override
  String get certErrorEmptyFingerprint =>
      'Failed to calculate certificate fingerprint.';

  @override
  String get certErrorUnknown =>
      'An unexpected error occurred while adding the certificate.';

  @override
  String get welcomeTitle => 'Welcome to Gatuno';

  @override
  String get welcomeInstructions =>
      'Please enter your server API URL to continue.';

  @override
  String get welcomeConnect => 'Connect';

  @override
  String get commonLogout => 'Sign Out';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonGuest => 'Guest';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorMessage => 'An unexpected error occurred.';

  @override
  String get errorRetry => 'Retry';

  @override
  String get errorBack => 'Go Back';

  @override
  String get commonPrevious => 'Previous';

  @override
  String get commonNext => 'Next';

  @override
  String commonPage(int page) {
    return 'Page $page';
  }

  @override
  String commonPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get readingDeferredDocumentMessage =>
      'PDF and EPUB support is coming soon.';

  @override
  String get readingNextChapter => 'Next Chapter';

  @override
  String get readingPreviousChapter => 'Previous Chapter';

  @override
  String get readingFinished => 'You\'ve reached the end of this chapter.';

  @override
  String get readingSettingsTitle => 'Reading settings';

  @override
  String get readingSettingsAction => 'Settings';

  @override
  String get readingThemeTitle => 'Reading theme';

  @override
  String get readingThemeStandard => 'Default';

  @override
  String get readingThemeSepia => 'Sepia';

  @override
  String get readingThemeCream => 'Cream';

  @override
  String get readingThemeHighContrast => 'High contrast';

  @override
  String get readingFontFamily => 'Font';

  @override
  String get readingFontFamilyDesc => 'Text family';

  @override
  String get readingFontSerif => 'Serif';

  @override
  String get readingFontSans => 'Sans-serif';

  @override
  String get readingFontLexend => 'Lexend';

  @override
  String get readingFontAtkinson => 'Atkinson Hyperlegible';

  @override
  String get readingFontOpenDyslexic => 'OpenDyslexic';

  @override
  String readingFontSize(int size) {
    return 'Font size (${size}px)';
  }

  @override
  String get readingFontSizeDesc => 'A- / A+';

  @override
  String get readingDecreaseFontSize => 'Decrease font size';

  @override
  String get readingIncreaseFontSize => 'Increase font size';

  @override
  String readingLineHeight(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String valueString = valueNumberFormat.format(value);

    return 'Line spacing ($valueString)';
  }

  @override
  String get readingLineHeightDesc => 'Distance between lines';

  @override
  String get readingDecreaseLineHeight => 'Decrease line spacing';

  @override
  String get readingIncreaseLineHeight => 'Increase line spacing';

  @override
  String get readingAlignment => 'Alignment';

  @override
  String get readingAlignmentDesc => 'Left, center or justified';

  @override
  String get readingAlignLeft => 'Left';

  @override
  String get readingAlignCenter => 'Center';

  @override
  String get readingAlignJustify => 'Justified';

  @override
  String booksDocumentFormat(String format) {
    return 'Format: $format';
  }

  @override
  String get booksUnknownFormat => 'Unknown';

  @override
  String get bookRequestsTitle => 'Book Requests';

  @override
  String get bookRequestsEmpty => 'No requests found.';

  @override
  String get bookRequestsCreateTitle => 'New Request';

  @override
  String get bookRequestsFormTitle => 'Book Title';

  @override
  String get bookRequestsFormAuthor => 'Author';

  @override
  String get bookRequestsFormSubmit => 'Submit Request';

  @override
  String get bookRequestsSuccess => 'Request created successfully!';

  @override
  String get homeCtaTitle => 'Can\'t find what you\'re looking for?';

  @override
  String get homeCtaDescription =>
      'Request a new book to be added to our collection. We\'ll review it as soon as possible.';

  @override
  String get bookRequestsFormUrl => 'URL';

  @override
  String get bookRequestsFormReason => 'Reason (optional)';

  @override
  String get homeCtaSignInButton => 'Sign In to Request';

  @override
  String get bookRequestsFormTitleRequired => 'Please enter a title';

  @override
  String get bookRequestsFormUrlRequired => 'Please enter a URL';

  @override
  String get bookRequestsFormUrlInvalid => 'Please enter a valid URL';

  @override
  String get bookRequestsCardUrl => 'URL';

  @override
  String get bookRequestsCardReason => 'Reason';

  @override
  String get bookRequestsCardRejection => 'Rejection Message';

  @override
  String bookRequestsCardDate(String date) {
    return 'Requested on $date';
  }

  @override
  String get bookRequestStatusPending => 'PENDING';

  @override
  String get bookRequestStatusApproved => 'APPROVED';

  @override
  String get bookRequestStatusRejected => 'REJECTED';

  @override
  String get userImageEditAvatar => 'Change profile photo';

  @override
  String get userImageEditBanner => 'Change banner image';

  @override
  String get userImageSourceGallery => 'Choose from gallery';

  @override
  String get userImageSourceCamera => 'Take a photo';

  @override
  String get userImageErrorType => 'Use a PNG, JPEG or WebP image.';

  @override
  String userImageErrorTooLarge(int maxMb) {
    return 'This image is too large. The limit is $maxMb MB.';
  }

  @override
  String get userImageErrorForbidden =>
      'You don\'t have permission to change this image.';

  @override
  String get userImageErrorNetwork =>
      'Could not upload the image. Check your connection and try again.';

  @override
  String get userImageErrorUnknown =>
      'Something went wrong with this image. Please try again.';

  @override
  String get mfaTitle => 'Two-factor authentication';

  @override
  String get mfaStatusEnabled => 'Two-factor authentication is on';

  @override
  String get mfaStatusDisabled => 'Two-factor authentication is off';

  @override
  String mfaBackupCodesRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count backup codes left',
      one: '1 backup code left',
      zero: 'No backup codes left',
    );
    return '$_temp0';
  }

  @override
  String get mfaEnableButton => 'Enable';

  @override
  String get mfaDisableButton => 'Disable';

  @override
  String get mfaReconfigureButton => 'Reconfigure';

  @override
  String get mfaReconfigureTitle => 'Reconfigure two-factor authentication?';

  @override
  String get mfaReconfigureWarning =>
      'Your current authenticator and all backup codes will stop working immediately.';

  @override
  String get mfaReconfigureConfirm => 'Reconfigure';

  @override
  String get mfaDisableTitle => 'Disable two-factor authentication';

  @override
  String get mfaDisableDescription =>
      'Enter a code from your authenticator app or a backup code.';

  @override
  String get mfaDisableConfirm => 'Disable';

  @override
  String get mfaSetupInstructions =>
      'Add this secret to your authenticator app (or password manager), then enter the 6-digit code it shows.';

  @override
  String get mfaCopySecret => 'Copy secret';

  @override
  String get mfaOpenAuthenticator => 'Open in authenticator app';

  @override
  String get mfaCopied => 'Copied';

  @override
  String get mfaConfirmButton => 'Confirm';

  @override
  String get mfaBackupCodesTitle => 'Save your backup codes';

  @override
  String get mfaBackupCodesWarning =>
      'Each code works once if you lose access to your authenticator. They will not be shown again.';

  @override
  String get mfaShareCodes => 'Save or share';

  @override
  String get mfaCopyCodes => 'Copy all';

  @override
  String get mfaSavedConfirm => 'I saved these codes';

  @override
  String get mfaDoneButton => 'Done';

  @override
  String get mfaRetryButton => 'Try again';

  @override
  String get mfaCodeLabel => 'Authentication code';

  @override
  String get mfaCodeRequired => 'Enter your authentication code';

  @override
  String get mfaChallengeTitle => 'Verify it\'s you';

  @override
  String get mfaChallengeDescription =>
      'Enter the 6-digit code from your authenticator app, or a backup code.';

  @override
  String get mfaVerifyButton => 'Verify';

  @override
  String get mfaErrorInvalidCode => 'That code is not valid. Try again.';

  @override
  String get mfaErrorTooManyAttempts =>
      'Too many attempts. Wait a minute and try again.';

  @override
  String get mfaErrorChallengeExpired =>
      'Verification expired. Please sign in again.';

  @override
  String get mfaErrorNetwork =>
      'Could not reach the server. Check your connection.';

  @override
  String get mfaErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get settingsMfaDesc =>
      'Protect your account with an authenticator app';

  @override
  String get mfaNoAuthenticatorApp =>
      'Could not open an authenticator app. Copy the secret and add it manually.';

  @override
  String get mfaSaveCodesFirst =>
      'Save your backup codes before leaving this screen.';

  @override
  String get appLockTitle => 'App lock';

  @override
  String get settingsAppLockDesc =>
      'Require your fingerprint, face or device PIN to open Gatuno';

  @override
  String get appLockSwitchTitle => 'Lock Gatuno';

  @override
  String get appLockSwitchDesc =>
      'Ask for your fingerprint, face or device PIN when you open the app';

  @override
  String get appLockSwitchDescBiometricOnly =>
      'Ask for your fingerprint or face when you open the app';

  @override
  String get appLockUnsupportedDesc =>
      'This device has no screen lock, so Gatuno cannot be locked.';

  @override
  String get appLockUnsupportedEnabledDesc =>
      'This device has no screen lock. Set one in the system settings to unlock Gatuno or turn the lock off.';

  @override
  String get appLockGraceTitle => 'Lock after leaving the app';

  @override
  String get appLockGraceImmediately => 'Immediately';

  @override
  String get appLockGraceThirtySeconds => 'After 30 seconds';

  @override
  String get appLockGraceOneMinute => 'After 1 minute';

  @override
  String get appLockGraceFiveMinutes => 'After 5 minutes';

  @override
  String get appLockGraceFifteenMinutes => 'After 15 minutes';

  @override
  String get appLockFallbackTitle => 'Allow device PIN, pattern or passcode';

  @override
  String get appLockFallbackOnDesc =>
      'Used when your fingerprint or face is unavailable. Turning this off can lock you out of Gatuno after a biometric lockout.';

  @override
  String get appLockFallbackOffDesc =>
      'If biometrics get locked out, Gatuno stays locked until the device allows them again.';

  @override
  String get appLockConfirmReason => 'Confirm it\'s you to change the app lock';

  @override
  String get appLockFallbackNeedsBiometric =>
      'Enroll a fingerprint or face in the system settings before turning off the device PIN.';

  @override
  String get appLockFallbackNoSensor =>
      'This device has no fingerprint or face sensor, so the device PIN must stay allowed.';

  @override
  String get appLockEnableNeedsBiometric =>
      'Allow the device PIN below, or enroll a fingerprint or face in the system settings.';

  @override
  String get appLockPromptHint => 'Use your fingerprint or face';

  @override
  String get appLockPromptHintWithCredential =>
      'Use your fingerprint, face or device PIN';

  @override
  String get appLockPromptReason => 'Unlock Gatuno';

  @override
  String get appLockLockedTitle => 'Gatuno is locked';

  @override
  String get appLockLockedDesc =>
      'Use your fingerprint, face or device PIN to continue';

  @override
  String get appLockLockedDescBiometricOnly =>
      'Use your fingerprint or face to continue';

  @override
  String get appLockUnlockButton => 'Unlock';

  @override
  String get appLockRetryButton => 'Try again';

  @override
  String get appLockErrorCancelled => 'Unlock cancelled';

  @override
  String get appLockErrorLockedOut =>
      'Too many attempts. Biometrics are locked for now.';

  @override
  String get appLockErrorNoCredentials =>
      'No screen lock is set on this device. Set one in the system settings.';

  @override
  String get appLockErrorNoBiometrics =>
      'No fingerprint or face is enrolled on this device. Enroll one in the system settings to unlock Gatuno.';

  @override
  String get appLockErrorNoBiometricHardware =>
      'No fingerprint or face sensor is available on this device.';

  @override
  String get appLockErrorSave => 'Could not save the setting. Try again.';

  @override
  String get appLockErrorUnavailable =>
      'Device authentication is not available right now. Try again in a moment.';

  @override
  String get appLockErrorFailed => 'Could not verify it\'s you. Try again.';

  @override
  String get readingAccessibilityTitle => 'Accessibility';

  @override
  String get readingAccessibilityDesc =>
      'Dyslexia mode, spacing, line width, ruler';

  @override
  String get readingDyslexiaTitle => 'Dyslexia mode';

  @override
  String get readingDyslexiaDesc =>
      'Applies the legibility recommendations at once. You can still adjust each item below.';

  @override
  String readingChipFont(String name) {
    return 'Font $name';
  }

  @override
  String readingChipAlignment(String name) {
    return 'Alignment: $name';
  }

  @override
  String readingChipLetters(String percent) {
    return 'Letters +$percent%';
  }

  @override
  String readingChipWords(String percent) {
    return 'Words +$percent%';
  }

  @override
  String readingChipLine(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String valueString = valueNumberFormat.format(value);

    return 'Line $valueString';
  }

  @override
  String readingChipWidth(int chars) {
    return '~$chars characters';
  }

  @override
  String readingChipBackground(String name) {
    return '$name background';
  }

  @override
  String get readingChipNoItalics => 'No italics';

  @override
  String get readingChipRuler => 'Reading ruler';

  @override
  String readingLetterSpacing(int percent) {
    return 'Letter spacing (+$percent%)';
  }

  @override
  String get readingLetterSpacingDesc => 'Separates the letters';

  @override
  String get readingDecreaseLetterSpacing => 'Decrease letter spacing';

  @override
  String get readingIncreaseLetterSpacing => 'Increase letter spacing';

  @override
  String readingWordSpacing(int percent) {
    return 'Word spacing (+$percent%)';
  }

  @override
  String get readingWordSpacingDesc => 'Separates the words';

  @override
  String get readingDecreaseWordSpacing => 'Decrease word spacing';

  @override
  String get readingIncreaseWordSpacing => 'Increase word spacing';

  @override
  String readingLineWidth(int chars) {
    return 'Line width ($chars characters)';
  }

  @override
  String get readingLineWidthOff => 'Line width (no limit)';

  @override
  String get readingLineWidthDesc => 'Keeps lines short';

  @override
  String get readingDecreaseLineWidth => 'Decrease line width';

  @override
  String get readingIncreaseLineWidth => 'Increase line width';

  @override
  String get readingSuppressItalics => 'No italics';

  @override
  String get readingSuppressItalicsDesc => 'Shows emphasised text as regular';

  @override
  String get readingRulerTitle => 'Reading ruler';

  @override
  String get readingRulerDesc => 'Highlights the current line';

  @override
  String get readingRulerSemantics =>
      'Reading ruler. Swipe up or down to move it.';

  @override
  String get offlineBannerMessage => 'Offline: showing saved data';

  @override
  String get offlineEmptyTitle => 'You\'re offline';

  @override
  String get offlineEmptyMessage =>
      'This isn\'t saved on this device yet. It loads once the server is reachable again.';
}
