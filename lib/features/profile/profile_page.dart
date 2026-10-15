import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/features/auth/auth_rules.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const String _placeholderName = 'Jane Doe';
const String _placeholderEmail = 'janedoe04@gmail.com';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(userProfileProvider);
    final name = (profile?.name.isNotEmpty ?? false)
        ? profile!.name
        : _placeholderName;
    final email = (profile?.email.isNotEmpty ?? false)
        ? profile!.email
        : _placeholderEmail;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.gutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: AppBackButton(
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Avatar placeholder
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Name
              Text(name, style: BrandText.headline(context, fontSize: 26)),
              const SizedBox(height: AppSpacing.xs),

              // Email
              InkWell(
                onTap: () => _editEmail(context, ref, email),
                borderRadius: BorderRadius.circular(AppRadius.control),
                splashColor: scheme.onSurface.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.edit, size: 16, color: scheme.onSurface),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Actions
              const Divider(),
              _MenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                showTrailing: true,
                onTap: () => context.push('/change-password'),
              ),
              const Divider(),
              _MenuItem(
                icon: Icons.logout,
                title: 'Log out',
                showTrailing: false,
                onTap: () {
                  // TODO: Implement Log out logic
                },
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editEmail(
    BuildContext context,
    WidgetRef ref,
    String currentEmail,
  ) async {
    final updated = await showDialog<String>(
      context: context,
      builder: (_) => _EditEmailDialog(initialEmail: currentEmail),
    );

    if (updated == null || updated == currentEmail || !context.mounted) return;

    ref.read(userProfileProvider.notifier).updateEmail(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Email updated to $updated')));
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.showTrailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool showTrailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      splashColor: scheme.onSurface.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurface, size: 22),
            const SizedBox(width: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            if (showTrailing)
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _EditEmailDialog extends StatefulWidget {
  const _EditEmailDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_EditEmailDialog> createState() => _EditEmailDialogState();
}

class _EditEmailDialogState extends State<_EditEmailDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialEmail,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (!AuthRules.isEmail(value)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Edit email'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'name@example.com',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: _save,
          child: Text(
            'Save',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: BrandText.accent(context),
            ),
          ),
        ),
      ],
    );
  }
}
