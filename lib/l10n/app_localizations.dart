import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_my.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('my'),
  ];

  /// No description provided for @darkmode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkmode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @goLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login Page'**
  String get goLogin;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete ?'**
  String get confirmDelete;

  /// No description provided for @successDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get successDelete;

  /// No description provided for @failDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete !!'**
  String get failDelete;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email...'**
  String get enterEmail;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter Name...'**
  String get enterName;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password...'**
  String get enterPassword;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Address...'**
  String get enterAddress;

  /// No description provided for @enterRole.
  ///
  /// In en, this message translates to:
  /// **'Enter Role...'**
  String get enterRole;

  /// No description provided for @publishPosts.
  ///
  /// In en, this message translates to:
  /// **'All Published Posts'**
  String get publishPosts;

  /// No description provided for @addTodoPage.
  ///
  /// In en, this message translates to:
  /// **'Todo Add Page'**
  String get addTodoPage;

  /// No description provided for @updateTodoPage.
  ///
  /// In en, this message translates to:
  /// **'Todo Update Page'**
  String get updateTodoPage;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Title....'**
  String get enterTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter Description....'**
  String get enterDescription;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @unpublish.
  ///
  /// In en, this message translates to:
  /// **'UnPublish'**
  String get unpublish;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @adminHomePage.
  ///
  /// In en, this message translates to:
  /// **'Admin Home Page'**
  String get adminHomePage;

  /// No description provided for @userHomePage.
  ///
  /// In en, this message translates to:
  /// **'User Home Page'**
  String get userHomePage;

  /// No description provided for @userAddPage.
  ///
  /// In en, this message translates to:
  /// **'User Add Page'**
  String get userAddPage;

  /// No description provided for @userUpdatePage.
  ///
  /// In en, this message translates to:
  /// **'User Update Page'**
  String get userUpdatePage;

  /// No description provided for @successAdd.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get successAdd;

  /// No description provided for @failAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add !'**
  String get failAdd;

  /// No description provided for @successUpdate.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get successUpdate;

  /// No description provided for @failUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update !'**
  String get failUpdate;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @likedPosts.
  ///
  /// In en, this message translates to:
  /// **'Recently Liked Post'**
  String get likedPosts;

  /// No description provided for @yourPosts.
  ///
  /// In en, this message translates to:
  /// **'All Your Todo Posts'**
  String get yourPosts;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @userList.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get userList;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginPage.
  ///
  /// In en, this message translates to:
  /// **'Login Page'**
  String get loginPage;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forgetPassword;

  /// No description provided for @successLogin.
  ///
  /// In en, this message translates to:
  /// **'Login Success ! '**
  String get successLogin;

  /// No description provided for @failLogin.
  ///
  /// In en, this message translates to:
  /// **'Failed to login'**
  String get failLogin;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome  '**
  String get welcome;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginGoogle;

  /// No description provided for @registerPage.
  ///
  /// In en, this message translates to:
  /// **'Register Page'**
  String get registerPage;

  /// No description provided for @askRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register Here !!'**
  String get askRegister;

  /// No description provided for @signinGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signinGoogle;

  /// No description provided for @successGoogleSignin.
  ///
  /// In en, this message translates to:
  /// **'Google successfully signin'**
  String get successGoogleSignin;

  /// No description provided for @askLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login Here !!'**
  String get askLogin;

  /// No description provided for @invalidEmailPsw.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidEmailPsw;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to logout ?'**
  String get confirmLogout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @forgetPage.
  ///
  /// In en, this message translates to:
  /// **'Forget Password Page'**
  String get forgetPage;

  /// No description provided for @emailSent1.
  ///
  /// In en, this message translates to:
  /// **'Email Sent to '**
  String get emailSent1;

  /// No description provided for @emailSent2.
  ///
  /// In en, this message translates to:
  /// **'to change your password'**
  String get emailSent2;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noteForget.
  ///
  /// In en, this message translates to:
  /// **'🔔🔔 If you finished reset your password , return login and enter your email and your reset(new) password. 🔔🔔'**
  String get noteForget;

  /// No description provided for @verifySent.
  ///
  /// In en, this message translates to:
  /// **'Verification Email has been sent again.'**
  String get verifySent;

  /// No description provided for @verifySentEmail.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to:'**
  String get verifySentEmail;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verify;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendEmail;

  /// No description provided for @successVerify.
  ///
  /// In en, this message translates to:
  /// **'Your email verification is successful.'**
  String get successVerify;

  /// No description provided for @checkVerify.
  ///
  /// In en, this message translates to:
  /// **'Check if Email is Verified'**
  String get checkVerify;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined - '**
  String get joined;

  /// No description provided for @confirmPsw.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPsw;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Password dose not match'**
  String get passwordNotMatch;

  /// No description provided for @oldPsw.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPsw;

  /// No description provided for @enterOldPsw.
  ///
  /// In en, this message translates to:
  /// **'Enter Old Password'**
  String get enterOldPsw;

  /// No description provided for @newPsw.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPsw;

  /// No description provided for @enternewPsw.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get enternewPsw;

  /// No description provided for @retypeNewPsw.
  ///
  /// In en, this message translates to:
  /// **'Retype New Password'**
  String get retypeNewPsw;

  /// No description provided for @enterretypeNewPsw.
  ///
  /// In en, this message translates to:
  /// **'Enter Retype Password'**
  String get enterretypeNewPsw;

  /// No description provided for @changePsw.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePsw;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
