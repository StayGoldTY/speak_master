import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/community.dart';
import 'service_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

const _authFieldUnset = Object();

class AuthState {
  final AuthStatus status;
  final sb.User? user;
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final String? feedbackMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.feedbackMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    sb.User? user,
    UserProfile? profile,
    bool? isLoading,
    Object? errorMessage = _authFieldUnset,
    Object? feedbackMessage = _authFieldUnset,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _authFieldUnset)
          ? this.errorMessage
          : errorMessage as String?,
      feedbackMessage: identical(feedbackMessage, _authFieldUnset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
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
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
      );
      _loadProfile();
      _syncProgress();
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _authSub = authService.authStateChanges.listen((event) {
      final session = event.session;
      if (session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
        );
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
      if (profile != null) {
        state = state.copyWith(profile: profile);
      }
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

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String? name,
  ) async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) {
      state = state.copyWith(errorMessage: '当前环境还没有接入账号服务，暂时不能注册。');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      feedbackMessage: null,
    );

    try {
      final response = await auth.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        feedbackMessage: response.session != null
            ? '注册成功，已自动登录。'
            : '注册请求已提交，请留意邮箱里的验证邮件。',
      );
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableAuthError(e),
      );
      return false;
    } on sb.PostgrestException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableProfileError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '注册失败，请稍后再试。');
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) {
      state = state.copyWith(errorMessage: '当前环境还没有接入账号服务，暂时不能登录。');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      feedbackMessage: null,
    );

    try {
      await auth.signInWithEmail(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        feedbackMessage: '登录成功，正在同步你的账号资料。',
      );
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableAuthError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '登录失败，请稍后再试。');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) {
      state = state.copyWith(errorMessage: '当前环境还没有接入 Google 登录。');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      feedbackMessage: null,
    );

    try {
      final success = await auth.signInWithGoogle();
      state = state.copyWith(
        isLoading: false,
        errorMessage: success ? null : '未能发起 Google 登录，请稍后再试。',
        feedbackMessage: success ? '已发起 Google 登录，请继续完成授权。' : null,
      );
      return success;
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableAuthError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google 登录暂时不可用，请稍后再试。',
      );
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) {
      state = state.copyWith(errorMessage: '当前环境还没有接入 Apple 登录。');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      feedbackMessage: null,
    );

    try {
      final success = await auth.signInWithApple();
      state = state.copyWith(
        isLoading: false,
        errorMessage: success ? null : '未能发起 Apple 登录，请稍后再试。',
        feedbackMessage: success ? '已发起 Apple 登录，请继续完成授权。' : null,
      );
      return success;
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableAuthError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Apple 登录暂时不可用，请稍后再试。',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _ref.read(authServiceProvider)?.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> resetPassword(String email) async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) {
      state = state.copyWith(errorMessage: '当前环境还没有接入账号服务，暂时不能重置密码。');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      feedbackMessage: null,
    );

    try {
      await auth.resetPassword(email);
      state = state.copyWith(
        isLoading: false,
        feedbackMessage: '重置邮件已发送，请留意收件箱。',
      );
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableAuthError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '重置邮件发送失败，请稍后再试。');
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? accentPreference,
  }) async {
    final auth = _ref.read(authServiceProvider);
    if (auth == null) {
      state = state.copyWith(errorMessage: '当前环境还没有接入账号资料同步能力。');
      return false;
    }

    final normalizedDisplayName = displayName?.trim();
    final normalizedUsername = username?.trim() ?? '';
    final normalizedAvatarUrl = avatarUrl?.trim() ?? '';

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      feedbackMessage: null,
    );

    try {
      await auth.updateProfile(
        displayName: normalizedDisplayName,
        username: normalizedUsername,
        avatarUrl: normalizedAvatarUrl,
        accentPreference: accentPreference,
      );

      final profile = state.profile;
      if (profile != null) {
        state = state.copyWith(
          isLoading: false,
          profile: profile.copyWith(
            displayName: normalizedDisplayName,
            username: normalizedUsername,
            avatarUrl: normalizedAvatarUrl,
            accentPreference: accentPreference,
          ),
          errorMessage: null,
          feedbackMessage: '账号资料已同步更新。',
        );
      } else {
        await _loadProfile();
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          feedbackMessage: '账号资料已同步更新。',
        );
      }

      return true;
    } on sb.PostgrestException catch (e) {
      debugPrint('Failed to update profile: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableProfileError(e),
      );
      return false;
    } catch (e) {
      debugPrint('Failed to update profile: $e');
      state = state.copyWith(isLoading: false, errorMessage: '资料保存失败，请稍后再试。');
      return false;
    }
  }

  Future<void> updateAccentPreference(String accentPreference) async {
    try {
      await updateProfile(accentPreference: accentPreference);
    } catch (e) {
      debugPrint('Failed to update accent preference: $e');
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, feedbackMessage: null);
  }

  String _readableAuthError(sb.AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return '邮箱或密码不正确，请重新输入。';
    }
    if (message.contains('email not confirmed')) {
      return '邮箱还没有完成验证，请先去收件箱确认。';
    }
    if (message.contains('user already registered')) {
      return '这个邮箱已经注册过了，直接登录即可。';
    }
    if (message.contains('password')) {
      return '密码不符合要求，请至少使用 6 位字符。';
    }
    if (message.contains('rate limit')) {
      return '操作太频繁了，请稍后再试。';
    }
    if (message.contains('network')) {
      return '网络连接失败，请检查后重试。';
    }

    return '账号操作失败：${error.message}';
  }

  String _readableProfileError(sb.PostgrestException error) {
    final message = error.message.toLowerCase();

    if (message.contains('duplicate key') || message.contains('unique')) {
      return '这个用户名已经被使用了，请换一个。';
    }
    if (message.contains('violates row-level security')) {
      return '当前账号没有权限修改这份资料。';
    }

    return '资料同步失败，请稍后再试。';
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
