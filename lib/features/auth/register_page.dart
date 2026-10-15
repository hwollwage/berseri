import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_button.dart';
import 'package:berseri/core/components/custom_logo.dart';
import 'package:berseri/core/components/custom_textfield.dart';
import 'package:berseri/features/auth/auth_rules.dart';
import 'package:berseri/features/auth/registered_accounts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validationError() {
    final emailError = AuthRules.emailError(_emailController.text);
    if (emailError != null) return emailError;

    if (_usernameController.text.trim().isEmpty) {
      return 'Please enter a username.';
    }

    final passwordError = AuthRules.passwordError(_passwordController.text);
    if (passwordError != null) return passwordError;

    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _warnAccountExists(String email) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account already exists'),
        content: Text(
          'An account for $email is already made. Please log in with that '
          'account instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final error = _validationError();
    if (error != null) {
      _showMessage(error);
      return;
    }

    final email = _emailController.text.trim();
    final accounts = ref.read(registeredAccountsProvider.notifier);

    if (accounts.contains(email)) {
      await _warnAccountExists(email);
      if (!mounted) return;
      context.go('/auth/login');
      return;
    }

    accounts.add(email);
    _showMessage('Account created. Please log in with your new account.');
    context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo & app name ─────────────────────────────────────
                  const Center(
                    child: BerseriLogo(icon: Icons.wb_sunny_rounded),
                  ),

                  const SizedBox(height: 40),

                  // ── Headline ────────────────────────────────────────────
                  RichText(
                    text: TextSpan(
                      style: BrandText.headline(context, fontSize: 28),
                      children: [
                        const TextSpan(text: 'Know Your Skin '),
                        TextSpan(
                          text: 'Better',
                          style: TextStyle(color: scheme.primary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Discover what your skin truly needs.',
                    style: BrandText.body(context),
                  ),

                  const SizedBox(height: 36),

                  // ── Email ───────────────────────────────────────────────
                  CustomTextfield(
                    label: 'Email address',
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Username ────────────────────────────────────────────
                  CustomTextfield(
                    label: 'Username',
                    hint: 'johndoe123',
                    controller: _usernameController,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Password ────────────────────────────────────────────
                  CustomTextfield(
                    label: 'Password',
                    hint: 'min. 8 characters',
                    controller: _passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Confirm password ────────────────────────────────────
                  CustomTextfield(
                    label: 'Confirm password',
                    hint: 're-enter your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Create account button ───────────────────────────────
                  CustomButton(
                    text: 'Create account >',
                    onPressed: _submit,
                  ),

                  const Spacer(),

                  // ── Login link ──────────────────────────────────────────
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.go('/auth/login'),
                                child: Text(
                                  'Login',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: BrandText.accent(context),
                                    decoration: TextDecoration.underline,
                                    decorationColor: BrandText.accent(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
