import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_button.dart';
import 'package:berseri/core/components/custom_logo.dart';
import 'package:berseri/core/components/custom_textfield.dart';
import 'package:berseri/features/auth/auth_rules.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sign-in screen.
///
/// Colours, type and field/button decoration all come from `AppTheme` and the
/// shared components — the page itself only decides layout and copy.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final error =
        AuthRules.loginIdentifierError(_emailController.text) ??
        (_passwordController.text.isEmpty
            ? 'Please enter your password.'
            : null);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.go('/');
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

                  // ── Username / email ────────────────────────────────────
                  CustomTextfield(
                    label: 'Username or email address',
                    hint: 'username or name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Password ────────────────────────────────────────────
                  CustomTextfield(
                    label: 'Password',
                    hint: 'min. 8 characters with 1 unique character',
                    controller: _passwordController,
                    isPassword: true,
                    labelAction: GestureDetector(
                      onTap: () {
                        // TODO: ngisi lupa password
                      },
                      child: Text(
                        'Forgot?',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: BrandText.accent(context),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Login button ────────────────────────────────────────
                  CustomButton(text: 'Login', onPressed: _submit),

                  const SizedBox(height: 24),

                  // ── Or continue with ────────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          'or continue with',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Provider buttons ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          onTap: () {
                            // TODO: Google sign-in
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          onTap: () {
                            // TODO: Apple sign-in
                          },
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Sign up link ────────────────────────────────────────
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'New to Berseri? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.go('/auth/register'),
                                child: Text(
                                  'Create an account',
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
