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

  /// Azure Speech resource key. Prefer the Supabase secret of the same name
  /// so the key never ships in the web bundle. dart-define is only for local
  /// native/dev builds.
  static const azureSpeechKey = String.fromEnvironment('AZURE_SPEECH_KEY');

  /// Azure Speech region, e.g. `eastasia` or `eastus`.
  static const azureSpeechRegion = String.fromEnvironment('AZURE_SPEECH_REGION');

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';

  static bool get hasAzureSpeech =>
      azureSpeechKey.isNotEmpty && azureSpeechRegion.isNotEmpty;
}
