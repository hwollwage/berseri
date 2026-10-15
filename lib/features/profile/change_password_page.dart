import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_button.dart';
import 'package:berseri/core/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const int _minPasswordLength = 8;

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

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
    if (next.length < _minPasswordLength) {
      return 'New password must be at least $_minPasswordLength characters.';
    }
    if (next == current) {
      return 'New password must be different from the current one.';
    }
    if (next != confirm) {
      return 'New passwords do not match.';
    }
    return null;
  }

  void _submit() {
    final error = _validationError();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    Navigator.of(context).maybePop();
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
                hint: 'min. $_minPasswordLength characters',
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

              CustomButton(text: 'Save new password', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
