import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_button.dart';
import 'package:berseri/core/components/custom_textfield.dart';
import 'package:berseri/features/auth/auth_errors.dart';
import 'package:berseri/features/auth/auth_repository.dart';
import 'package:berseri/features/auth/auth_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validationError() {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      return 'Please fill in every field.';
    }

    final passwordError = AuthRules.passwordError(next);
    if (passwordError != null) return passwordError;

    if (next == current) {
      return 'New password must be different from the current one.';
    }
    if (next != confirm) {
      return 'New passwords do not match.';
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

    final repository = ref.read(authRepositoryProvider);

    try {
      try {
        await repository.verifyPassword(_currentController.text);
      } on AuthException catch (error) {
        if (!mounted) return;
        _showMessage(
          isInvalidCredentials(error)
              ? incorrectCurrentPasswordMessage
              : authErrorMessage(error),
        );
        return;
      }

      await repository.updatePassword(_newController.text);
      if (!mounted) return;
      _showMessage('Password updated.');
      Navigator.of(context).maybePop();
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                'Change Password',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pick a new password for your account. You stay signed in on '
                'this device.',
                style: BrandText.body(context),
              ),

              const SizedBox(height: AppSpacing.xxl),

              CustomTextfield(
                label: 'Current password',
                hint: 'enter your current password',
                controller: _currentController,
                isPassword: true,
              ),

              const SizedBox(height: AppSpacing.xl),

              CustomTextfield(
                label: 'New password',
                hint: 'min. ${AuthRules.minPasswordLength} characters',
                controller: _newController,
                isPassword: true,
              ),

              const SizedBox(height: AppSpacing.xl),

              CustomTextfield(
                label: 'Confirm new password',
                hint: 're-enter your new password',
                controller: _confirmController,
                isPassword: true,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              CustomButton(
                text: 'Save new password',
                onPressed: _submit,
                isLoading: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
