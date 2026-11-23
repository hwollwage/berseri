import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/features/auth/auth_errors.dart';
import 'package:berseri/features/auth/auth_repository.dart';
import 'package:berseri/features/auth/auth_rules.dart';
import 'package:berseri/features/notifications/notification_service.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const String _pendingEmailMessage =
    'Confirmation sent. Your email changes once you confirm it.';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(userProfileProvider);
    final name = profile?.name ?? '';
    final email = profile?.email ?? '';

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
              Text(name, style: BrandText.headline(context, fontSize: 26)),
              const SizedBox(height: AppSpacing.xs),
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
              const Divider(),
              _MenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                showTrailing: true,
                onTap: () => context.push('/change-password'),
              ),
              const Divider(),
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: 'Scan Reminder',
                showTrailing: true,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => const _ReminderSheet(),
                ),
              ),
              const Divider(),
              _MenuItem(
                icon: Icons.logout,
                title: 'Log out',
                showTrailing: false,
                onTap: () => _logout(context, ref),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
    }

    if (!context.mounted) return;
    context.go('/auth/login');
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

    try {
      await ref.read(authRepositoryProvider).updateEmail(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(_pendingEmailMessage)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
    }
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

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet();

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  static const _options = [1, 2, 3, 5, 7, 14, 30];

  bool _loaded = false;
  bool _enabled = true;
  int _days = 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await NotificationService.instance.loadSettings();
    if (!mounted) return;
    setState(() {
      _enabled = s.enabled;
      _days = s.intervalDays;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    debugPrint('Simpan ditekan: enabled=$_enabled days=$_days');
    if (_enabled) {
      await NotificationService.instance.requestPermission();
    }
    await NotificationService.instance.saveSettings(
      ReminderSettings(enabled: _enabled, intervalDays: _days),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _enabled
              ? 'Pengingat diatur setiap $_days hari'
              : 'Pengingat dimatikan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_loaded) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.gutter + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengingat Scan Wajah', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aktifkan pengingat'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          if (_enabled) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ingatkan jika tidak scan selama:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in _options)
                  ChoiceChip(
                    label: Text('$d hari'),
                    selected: _days == d,
                    onSelected: (_) => setState(() => _days = d),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('Simpan')),
          ),
        ],
      ),
    );
  }
}