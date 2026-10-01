/// Build-time configuration, read from `env.json` via
/// `flutter run --dart-define-from-file=env.json`.
library;

const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// False when the app was started without `env.json`, or the file still
/// holds the placeholder values.
bool get isSupabaseConfigured =>
    supabaseUrl.startsWith('https://') &&
    !supabaseUrl.contains('YOUR-PROJECT-ID') &&
    supabaseAnonKey.isNotEmpty &&
    !supabaseAnonKey.startsWith('paste-');

/// Deep link Supabase redirects to after Google sign-in / email links on
/// Android and iOS. Must also be listed in Supabase → Authentication → URL
/// Configuration → Redirect URLs.
const String mobileAuthRedirect = 'io.livrcheck.app://login-callback';
