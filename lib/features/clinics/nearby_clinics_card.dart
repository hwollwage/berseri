import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/text_link.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'clinic.dart';
import 'nearby_clinics_provider.dart';

Future<void> _openDirections(Clinic clinic) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=${clinic.latitude},${clinic.longitude}'
    '&travelmode=driving',
  );
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Tidak bisa membuka Google Maps untuk ${clinic.name}');
  }
}

Future<void> _callPhone(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  if (!await launchUrl(uri)) {
    debugPrint('Tidak bisa membuka dialer untuk nomor $phone');
  }
}

class NearbyClinicsCard extends ConsumerWidget {
  const NearbyClinicsCard({super.key, this.onSeeAll, this.onClinicTap});

  final VoidCallback? onSeeAll;
  final ValueChanged<Clinic>? onClinicTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final clinics = ref.watch(nearbyClinicsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text('Nearby clinics', style: BrandText.title(context)),
              ),
              if (onSeeAll != null)
                TextLink(label: 'See all', onTap: onSeeAll!),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Skin clinics close to where you are.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          clinics.when(
            loading: () => const _ClinicsSkeleton(),
            error: (e, _) => _errorView(e, ref),
            data: (list) {
              if (list.isEmpty) {
                return const _Message(
                  text: 'No clinics found near you yet.',
                );
              }
              final top = list.take(3).toList();
              return Column(
                children: [
                  for (var i = 0; i < top.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    ClinicTile(
                      clinic: top[i],
                      onTap: () => onClinicTap?.call(top[i]),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ClinicTile extends StatelessWidget {
  const ClinicTile({
    super.key,
    required this.clinic,
    required this.onTap,
    this.selected = false,
  });

  final Clinic clinic;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final meta = <String>[
      if (clinic.rating != null) '★ ${clinic.rating!.toStringAsFixed(1)}',
    ];

    return Material(
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        side: BorderSide(
          color: selected ? scheme.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_hospital_outlined,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clinic.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (meta.isNotEmpty || clinic.isOpen != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (meta.isNotEmpty)
                            Text(
                              meta.join(' · '),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          if (meta.isNotEmpty && clinic.isOpen != null)
                            const SizedBox(width: 8),
                          if (clinic.isOpen != null)
                            _StatusDot(open: clinic.isOpen!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Jarak + tombol aksi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    clinic.formattedDistance,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Telepon (hanya tampil jika ada nomor)
                      if (clinic.phone != null && clinic.phone!.isNotEmpty)
                        _ActionIcon(
                          icon: Icons.phone_outlined,
                          tooltip: 'Telepon klinik',
                          color: scheme.secondary,
                          onTap: () => _callPhone(clinic.phone!),
                        ),
                      if (clinic.phone != null && clinic.phone!.isNotEmpty)
                        const SizedBox(width: 6),
                      // Tombol Directions (selalu tampil)
                      _ActionIcon(
                        icon: Icons.directions_outlined,
                        tooltip: 'Rute ke klinik',
                        color: scheme.primary,
                        onTap: () => _openDirections(clinic),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tombol ikon kecil yang bisa diklik ────────────────────────────────────────
class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = open ? scheme.primary : scheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          open ? 'Open' : 'Closed',
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ClinicsSkeleton extends StatelessWidget {
  const _ClinicsSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _errorView(Object error, WidgetRef ref) {
  void retry() => retryNearbyClinics(ref, error);

  if (error is LocationException) {
    switch (error.issue) {
      case LocationIssue.serviceOff:
        return _Message(
          text: 'Turn on location services to see clinics near you.',
          actions: [
            ('Open settings', Geolocator.openLocationSettings),
            ('Try again', retry),
          ],
        );
      case LocationIssue.denied:
        return _Message(
          text: 'Location permission is needed to find clinics near you.',
          actions: [('Allow location', retry)],
        );
      case LocationIssue.deniedForever:
        return _Message(
          text: 'Location permission is blocked. Enable it in settings.',
          actions: [
            ('Open settings', Geolocator.openAppSettings),
            ('Try again', retry),
          ],
        );
      case LocationIssue.timeout:
        return _Message(
          text: "We couldn't get your location. Move somewhere with a clearer "
              'view of the sky and try again.',
          actions: [('Try again', retry)],
        );
    }
  }

  return _Message(
    text: "We couldn't load nearby clinics.",
    actions: [('Try again', retry)],
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actions = const []});

  final String text;
  final List<(String, VoidCallback)> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            children: [
              for (final a in actions) TextLink(label: a.$1, onTap: a.$2),
            ],
          ),
        ],
      ],
    );
  }
}