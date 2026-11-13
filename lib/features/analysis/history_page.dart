import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/features/analysis/analysis_entry.dart';
import 'package:berseri/features/analysis/analysis_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final history = ref.watch(analysisHistoryEntriesProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _BackButton(onTap: () => context.pop()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text(
                'Analysis History',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
            Expanded(
              child: history.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, _) => _ErrorState(
                  onRetry: () =>
                      ref.invalidate(analysisHistoryEntriesProvider),
                ),
                data: (entries) => entries.isEmpty
                    ? const _EmptyState()
                    : _HistoryList(entries: entries),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.entries});

  final List<AnalysisEntry> entries;

  @override
  Widget build(BuildContext context) {
    final groups = groupByMonth(entries);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        for (final group in groups) ...[
          _MonthHeading(label: group.label),
          const SizedBox(height: 12),
          for (final entry in group.entries) ...[
            _HistoryCard(
              entry: entry,
              onTap: () => context.push(
                '/analysis-result',
                extra: entry,
              ),
            ),
            if (entry != group.entries.last) const SizedBox(height: 10),
          ],
          if (group != groups.last) const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class HistoryGroup {
  const HistoryGroup({required this.label, required this.entries});

  final String label;
  final List<AnalysisEntry> entries;
}

List<HistoryGroup> groupByMonth(List<AnalysisEntry> entries) {
  final groups = <HistoryGroup>[];

  for (final entry in entries) {
    final isSameMonth =
        groups.isNotEmpty &&
        groups.last.entries.first.record.monthKey == entry.record.monthKey;

    if (isSameMonth) {
      groups.last.entries.add(entry);
    } else {
      groups.add(
        HistoryGroup(
          label: entry.record.monthLabel,
          entries: <AnalysisEntry>[entry],
        ),
      );
    }
  }

  return groups;
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.chevron_left_rounded,
            size: 26,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MonthHeading extends StatelessWidget {
  const _MonthHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry, required this.onTap});

  static const double _photoSize = 78;
  static const double _badgeSize = 34;
  static const EdgeInsets _padding = EdgeInsets.all(14);

  static const double _dateGap = 26;

  final AnalysisEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final record = entry.record;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: _padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Thumbnail(photoUrl: entry.photoUrl, size: _photoSize),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.shortDate,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: _dateGap),
                    Text(
                      record.skinTypeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    if (record.conditions.isNotEmpty)
                      Text(
                        record.conditions.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: _badgeSize,
                  width: _badgeSize,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_outward,
                    size: 18,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photoUrl, required this.size});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? _Fallback(size: size)
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _Fallback(size: size),
                errorBuilder: (context, _, _) => _Fallback(size: size),
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(
        Icons.face_retouching_natural,
        size: size * 0.5,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: scheme.error),
            const SizedBox(height: 12),
            Text(
              "We couldn't load your analysis history.",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 40,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No analysis yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run your first scan from the Analyze tab to build up your '
              'history.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
