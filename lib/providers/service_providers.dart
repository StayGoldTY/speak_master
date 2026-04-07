import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/community_service.dart';
import '../services/progress_sync_service.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final progressSyncServiceProvider = Provider<ProgressSyncService>((ref) {
  return ProgressSyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(storageServiceProvider),
  );
});

final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService(ref.watch(supabaseClientProvider));
});

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});
