import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_language.dart';
import '../config.dart';

/// Thin wrapper around Supabase Auth, so screens never talk to Supabase
/// directly. Accounts live in Supabase → Authentication → Users.
class AuthService {
  AuthService._();

  static GoTrueClient get _auth => Supabase.instance.client.auth;

  static User? get currentUser => _auth.currentUser;
  static Session? get currentSession => _auth.currentSession;
  static Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Where Supabase sends the user back after Google sign-in or an email
  /// link: the current site on web, the app's deep link on mobile.
  static String get _redirectUrl =>
      kIsWeb ? Uri.base.origin : mobileAuthRedirect;

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  /// Returns a response whose `session` is null when Supabase requires the
  /// user to confirm their email first.
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
      emailRedirectTo: _redirectUrl,
    );
  }

  /// Sends a 6-digit SMS code. [phone] must be in E.164 form, e.g.
  /// +919876543210. Needs an SMS provider set up in Supabase.
  static Future<void> sendPhoneOtp(String phone) {
    return _auth.signInWithOtp(phone: phone);
  }

  static Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String code,
  }) {
    return _auth.verifyOTP(phone: phone, token: code, type: OtpType.sms);
  }

  /// Opens Google's sign-in page. The session arrives later through
  /// [onAuthStateChange] once Google redirects back.
  static Future<bool> signInWithGoogle() {
    return _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _redirectUrl,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  static Future<void> sendPasswordReset(String email) {
    return _auth.resetPasswordForEmail(email, redirectTo: _redirectUrl);
  }

  static Future<void> updatePassword(String newPassword) {
    return _auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<void> signOut() => _auth.signOut();

  /// Permanently deletes the signed-in user's account and all their data
  /// (database function `delete_my_account`, migration 6), then signs out.
  static Future<void> deleteAccount() async {
    await Supabase.instance.client.rpc('delete_my_account');
    try {
      // The account no longer exists, so only clear the local session.
      await _auth.signOut(scope: SignOutScope.local);
    } catch (_) {}
  }

  /// Turns Supabase errors into a message fit to show the user.
  /// In debug builds the raw error is added, so problems can be diagnosed.
  static String describeError(Object error, String fallback) {
    debugPrint('LivrCheck error: ${error.runtimeType}: $error');
    if (error is AuthException) return error.message;
    if (error is PostgrestException) {
      return kDebugMode
          ? '${error.message} (code ${error.code})'
          : error.message;
    }
    return kDebugMode ? '$fallback\n$error' : fallback;
  }

  /// Translation key for errors we can explain in plain words (Supabase
  /// sends its messages in English), or null if the error is unknown.
  static String? errorKey(Object error) {
    final text =
        (error is AuthException
                ? error.message
                : error is PostgrestException
                ? error.message
                : error.toString())
            .toLowerCase();
    bool has(String part) => text.contains(part);
    if (has('rate limit')) return 'authRateLimited';
    if (has('already registered')) return 'authAlreadyRegistered';
    if (has('invalid login credentials')) return 'authInvalidLogin';
    if (has('email not confirmed')) return 'authEmailNotConfirmed';
    if (has('different from the old password')) return 'au_samePassword';
    if (has('password should be') || has('weak password')) {
      return 'au_weakPassword';
    }
    if (has('unable to validate email') || has('invalid email')) {
      return 'emailRequiredError';
    }
    if (has('signups not allowed') || has('signup is disabled')) {
      return 'au_signupDisabled';
    }
    if (has('token has expired') || has('otp expired') || has('otp_expired')) {
      return 'au_codeExpired';
    }
    if (has('user not found')) return 'au_userNotFound';
    if (has('not signed in') ||
        has('jwt expired') ||
        has('auth session missing')) {
      return 'au_sessionExpired';
    }
    if (has('failed to fetch') ||
        has('socketexception') ||
        has('clientexception') ||
        has('network')) {
      return 'au_noInternet';
    }
    return null;
  }

  /// [describeError] in the current language: known errors become a
  /// translated plain-language message, others fall back to the raw text.
  static String describeErrorFor(
    BuildContext context,
    Object error,
    String fallback,
  ) {
    final key = errorKey(error);
    if (key == null) return describeError(error, fallback);
    debugPrint('LivrCheck error: ${error.runtimeType}: $error');
    return context.t(key);
  }
}
