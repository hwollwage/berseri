import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_button.dart';
import 'package:berseri/core/components/custom_logo.dart';
import 'package:berseri/core/components/custom_textfield.dart';
import 'package:berseri/features/auth/auth_errors.dart';
import 'package:berseri/features/auth/auth_repository.dart';
import 'package:berseri/features/auth/auth_rules.dart';
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
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validationError() {
    final emailError = AuthRules.emailError(_emailController.text);
    if (emailError != null) return emailError;

    final nameError = AuthRules.fullNameError(_fullNameController.text);
    if (nameError != null) return nameError;

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

  Future<void> _submit() async {
    if (_submitting) return;

    final error = _validationError();
    if (error != null) {
      _showMessage(error);
      return;
    }

    setState(() => _submitting = true);

    try {
      final response = await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          );

      if (!mounted) return;

      if (response.session == null) {
        _showMessage('Check your email to confirm your account.');
        return;
      }

      if (!mounted) return;
      context.go('/');
    } catch (error) {
      if (!mounted) return;
      _showMessage(authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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

                  const Center(
                    child: BerseriLogo(icon: Icons.wb_sunny_rounded),
                  ),

                  const SizedBox(height: 40),

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

                  CustomTextfield(
                    label: 'Email address',
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomTextfield(
                    label: 'Full name',
                    hint: 'Jane Doe',
                    controller: _fullNameController,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomTextfield(
                    label: 'Password',
                    hint: 'min. 8 characters',
                    controller: _passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomTextfield(
                    label: 'Confirm password',
                    hint: 're-enter your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  CustomButton(
                    text: 'Create account',
                    onPressed: _submit,
                    isLoading: _submitting,
                  ),

                  const Spacer(),

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
