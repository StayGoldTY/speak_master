import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/community.dart';
import 'service_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final sb.User? user;
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    sb.User? user,
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  StreamSubscription<sb.AuthState>? _authSub;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final authService = _ref.read(authServiceProvider);
    if (authService == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    final currentUser = authService.currentUser;
    if (currentUser != null) {
      state = state.copyWith(status: AuthStatus.authenticated, user: currentUser);
      _loadProfile();
      _syncProgress();
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _authSub = authService.authStateChanges.listen((event) {
      final session = event.session;
      if (session != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: session.user);
        _loadProfile();
        _syncProgress();
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _ref.read(authServiceProvider)?.getProfile();
      if (profile != null) state = state.copyWith(profile: profile);
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    }
  }

  Future<void> _syncProgress() async {
    try {
      await _ref.read(progressSyncServiceProvider).syncLocalToCloud();
    } catch (e) {
      debugPrint('Failed to sync progress: $e');
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String? name) async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await auth.signUpWithEmail(email: email, password: password, displayName: name);
      state = state.copyWith(isLoading: false);
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await auth.signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _ref.read(authServiceProvider)?.signInWithGoogle();
    state = state.copyWith(isLoading: false);
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _ref.read(authServiceProvider)?.signInWithApple();
    state = state.copyWith(isLoading: false);
  }

  Future<void> signOut() async {
    await _ref.read(authServiceProvider)?.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetPassword(String email) async {
    await _ref.read(authServiceProvider)?.resetPassword(email);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
