class EnvConfig {
  EnvConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' && supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
