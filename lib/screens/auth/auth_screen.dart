import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

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

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(authState),
              const SizedBox(height: 16),
              _buildSubmitButton(authState),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildOAuthButtons(authState),
              const SizedBox(height: 24),
              _buildToggleMode(),
              const SizedBox(height: 16),
              _buildSkipButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.record_voice_over, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          '声临其境',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          _isLogin ? '欢迎回来，继续你的发音之旅' : '开始你的英语发音学习之旅',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
              validator: (v) {
                if (!_isLogin && (v == null || v.trim().isEmpty)) {
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
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '请输入邮箱';
              if (!v.contains('@')) return '请输入有效邮箱';
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
            validator: (v) {
              if (v == null || v.isEmpty) return '请输入密码';
              if (v.length < 6) return '密码至少 6 位';
              return null;
            },
          ),
          if (_isLogin) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
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
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
          child: Text('或', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
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
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isLogin ? '还没有账号？' : '已有账号？', style: const TextStyle(color: AppColors.textSecondary)),
        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: Text(_isLogin ? '立即注册' : '去登录', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Guest mode handled by router — just mark as unauthenticated and let router skip
          Navigator.of(context).pushReplacementNamed('/home');
        },
        child: const Text(
          '跳过，先体验一下',
          style: TextStyle(color: AppColors.textHint, fontSize: 13),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_isLogin) {
      ref.read(authProvider.notifier).signInWithEmail(email, password);
    } else {
      ref.read(authProvider.notifier).signUpWithEmail(email, password, name.isEmpty ? null : name);
    }
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在邮箱栏输入你的邮箱地址')),
      );
      return;
    }
    ref.read(authProvider.notifier).resetPassword(email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('重置邮件已发送，请查收'), backgroundColor: AppColors.successGreen),
    );
  }
}
