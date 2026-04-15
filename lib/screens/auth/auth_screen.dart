import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectTo;

  const AuthScreen({
    super.key,
    this.redirectTo,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String get _targetPath {
    final redirectTo = widget.redirectTo;
    if (redirectTo == null || redirectTo.isEmpty || !redirectTo.startsWith('/')) {
      return '/home';
    }

    return redirectTo;
  }

  bool get _willReturnToSource => _targetPath != '/home';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authService = ref.watch(authServiceProvider);
    final authAvailable = authService != null;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(next.errorMessage!),
                backgroundColor: AppColors.errorRed,
              ),
            );
          ref.read(authProvider.notifier).clearMessages();
        });
      }

      if (next.feedbackMessage != null && next.feedbackMessage != prev?.feedbackMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(next.feedbackMessage!),
                backgroundColor: AppColors.successGreen,
              ),
            );
          ref.read(authProvider.notifier).clearMessages();
        });
      }

      if (next.status == AuthStatus.authenticated && prev?.status != AuthStatus.authenticated) {
        context.go(_targetPath);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 28),
                  if (_willReturnToSource) ...[
                    const _InfoCard(
                      title: '登录后会回到刚才的页面',
                      body: '这次登录不是把你带回首页，而是为了继续刚才那一步操作。完成后会自动返回来源页。',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!authAvailable) ...[
                    const _InfoCard(
                      title: '当前是本地体验模式',
                      body: '这个环境还没有接入 Supabase 登录能力，所以现在不能真的注册、登录或找回密码。不过你仍然可以直接跳过，继续体验教程、练习和本地进度。',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (authAvailable) ...[
                    _buildForm(authState),
                    const SizedBox(height: 16),
                    _buildSubmitButton(authState),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildOAuthButtons(authState),
                    const SizedBox(height: 24),
                    _buildToggleMode(),
                  ] else ...[
                    const _InfoCard(
                      title: '这页现在还能做什么',
                      body: '你可以把它理解为“账户能力预留位”。正式接好后，这里会启用邮箱登录、第三方登录和资料同步。',
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSkipButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.record_voice_over, color: Colors.white, size: 42),
        ),
        const SizedBox(height: 18),
        Text(
          AppConstants.appName,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          _isLogin ? '登录后可以同步学习进度和个人偏好。' : '创建账号，让你的练习轨迹留得住。',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin) ...[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '昵称',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (!_isLogin && (value == null || value.trim().isEmpty)) {
                  return '请输入昵称';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '邮箱',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return '请输入邮箱';
              if (!value.contains('@')) return '请输入有效邮箱';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入密码';
              if (value.length < 6) return '密码至少 6 位';
              return null;
            },
          ),
          if (_isLogin) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: authState.isLoading ? null : _handleForgotPassword,
                child: const Text('忘记密码？', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AuthState authState) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _handleSubmit,
        child: authState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(_isLogin ? '登录' : '注册', style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('或者', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildOAuthButtons(AuthState authState) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading ? null : () => ref.read(authProvider.notifier).signInWithGoogle(),
            icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.accent)),
            label: const Text('使用 Google 登录'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading ? null : () => ref.read(authProvider.notifier).signInWithApple(),
            icon: const Icon(Icons.apple, size: 22),
            label: const Text('使用 Apple 登录'),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isLogin ? '还没有账号？' : '已经有账号？', style: const TextStyle(color: AppColors.textSecondary)),
        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: Text(_isLogin ? '去注册' : '去登录', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.go(_targetPath),
        child: Text(
          _willReturnToSource ? '先返回上一页' : '先跳过，继续体验',
          style: const TextStyle(color: AppColors.textHint, fontSize: 13),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_isLogin) {
      await ref.read(authProvider.notifier).signInWithEmail(email, password);
      return;
    }

    await ref.read(authProvider.notifier).signUpWithEmail(
          email,
          password,
          name.isEmpty ? null : name,
        );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在邮箱栏输入你的邮箱地址')),
      );
      return;
    }

    await ref.read(authProvider.notifier).resetPassword(email);
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.65),
          ),
        ],
      ),
    );
  }
}
