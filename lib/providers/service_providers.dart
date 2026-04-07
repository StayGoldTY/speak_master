import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/env_config.dart';
import '../services/auth_service.dart';
import '../services/community_service.dart';
import '../services/progress_sync_service.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!EnvConfig.isConfigured) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final authServiceProvider = Provider<AuthService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return AuthService(client);
});

final progressSyncServiceProvider = Provider<ProgressSyncService>((ref) {
  return ProgressSyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(storageServiceProvider),
  );
});

final communityServiceProvider = Provider<CommunityService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return CommunityService(client);
});

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});
